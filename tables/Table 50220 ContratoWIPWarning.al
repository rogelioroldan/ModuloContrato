table 50220 "Contrato WIP Warning"
{
    Caption = 'Contrato WIP Warning';
    DrillDownPageID = "Contrato WIP Warnings";
    LookupPageID = "Contrato WIP Warnings";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
        }
        field(2; "Contrato No."; Code[20])
        {
            Caption = 'Contrato No.';
            TableRelation = Contrato;
        }
        field(3; "Contrato Task No."; Code[20])
        {
            Caption = 'Contrato Task No.';
            TableRelation = "Contrato Task"."Contrato Task No.";
        }
        field(4; "Contrato WIP Total Entry No."; Integer)
        {
            Caption = 'Contrato WIP Total Entry No.';
            Editable = false;
            TableRelation = "Contrato WIP Total";
        }
        field(5; "Warning Message"; Text[250])
        {
            Caption = 'Warning Message';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Contrato No.", "Contrato Task No.")
        {
        }
        key(Key3; "Contrato WIP Total Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label '%1 is 0.';
        Text002: Label 'Cost completion is greater than 100%.';
        Text003: Label '%1 is negative.';

    procedure CreateEntries(ContratoWIPTotal: Record "Contrato WIP Total")
    var
        Contrato: Record Contrato;
        ShouldInsertWarnings: Boolean;
    begin
        Contrato.Get(ContratoWIPTotal."Contrato No.");
        ShouldInsertWarnings := not Contrato.Complete;
        OnCreateEntriesOnAfterCalcShouldInsertWarnings(ContratoWIPTotal, Contrato, ShouldInsertWarnings);
        if ShouldInsertWarnings then begin
            if ContratoWIPTotal."Contract (Total Price)" = 0 then
                InsertWarning(ContratoWIPTotal, StrSubstNo(Text001, ContratoWIPTotal.FieldCaption("Contract (Total Price)")));

            if ContratoWIPTotal."Schedule (Total Cost)" = 0 then
                InsertWarning(ContratoWIPTotal, StrSubstNo(Text001, ContratoWIPTotal.FieldCaption("Schedule (Total Cost)")));

            if ContratoWIPTotal."Schedule (Total Price)" = 0 then
                InsertWarning(ContratoWIPTotal, StrSubstNo(Text001, ContratoWIPTotal.FieldCaption("Schedule (Total Price)")));

            if ContratoWIPTotal."Usage (Total Cost)" > ContratoWIPTotal."Schedule (Total Cost)" then
                InsertWarning(ContratoWIPTotal, Text002);

            if ContratoWIPTotal."Calc. Recog. Sales Amount" < 0 then
                InsertWarning(ContratoWIPTotal, StrSubstNo(Text003, ContratoWIPTotal.FieldCaption("Calc. Recog. Sales Amount")));

            if ContratoWIPTotal."Calc. Recog. Costs Amount" < 0 then
                InsertWarning(ContratoWIPTotal, StrSubstNo(Text003, ContratoWIPTotal.FieldCaption("Calc. Recog. Costs Amount")));
        end;
        OnAfterCreateEntries(ContratoWIPTotal, Contrato);
    end;

    procedure DeleteEntries(ContratoWIPTotal: Record "Contrato WIP Total")
    begin
        SetRange("Contrato WIP Total Entry No.", ContratoWIPTotal."Entry No.");
        if not IsEmpty() then
            DeleteAll(true);
    end;

    procedure InsertWarning(ContratoWIPTotal: Record "Contrato WIP Total"; Message: Text[250])
    begin
        Reset();
        if FindLast() then
            "Entry No." += 1
        else
            "Entry No." := 1;
        "Contrato WIP Total Entry No." := ContratoWIPTotal."Entry No.";
        "Contrato No." := ContratoWIPTotal."Contrato No.";
        "Contrato Task No." := ContratoWIPTotal."Contrato Task No.";
        "Warning Message" := Message;
        OnInsertWarningOnBeforeInsert(Rec);
        Insert();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateEntries(ContratoWIPTotal: Record "Contrato WIP Total"; Contrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateEntriesOnAfterCalcShouldInsertWarnings(ContratoWIPTotal: Record "Contrato WIP Total"; Contrato: Record Contrato; var ShouldInsertWarnings: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertWarningOnBeforeInsert(var ContratoWIPWarning: Record "Contrato WIP Warning")
    begin
    end;
}

