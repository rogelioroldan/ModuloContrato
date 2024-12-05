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

    procedure CreateEntries(JobWIPTotal: Record "Contrato WIP Total")
    var
        Contrato: Record Contrato;
        ShouldInsertWarnings: Boolean;
    begin
        Contrato.Get(JobWIPTotal."Contrato No.");
        ShouldInsertWarnings := not Contrato.Complete;
        OnCreateEntriesOnAfterCalcShouldInsertWarnings(JobWIPTotal, Contrato, ShouldInsertWarnings);
        if ShouldInsertWarnings then begin
            if JobWIPTotal."Contract (Total Price)" = 0 then
                InsertWarning(JobWIPTotal, StrSubstNo(Text001, JobWIPTotal.FieldCaption("Contract (Total Price)")));

            if JobWIPTotal."Schedule (Total Cost)" = 0 then
                InsertWarning(JobWIPTotal, StrSubstNo(Text001, JobWIPTotal.FieldCaption("Schedule (Total Cost)")));

            if JobWIPTotal."Schedule (Total Price)" = 0 then
                InsertWarning(JobWIPTotal, StrSubstNo(Text001, JobWIPTotal.FieldCaption("Schedule (Total Price)")));

            if JobWIPTotal."Usage (Total Cost)" > JobWIPTotal."Schedule (Total Cost)" then
                InsertWarning(JobWIPTotal, Text002);

            if JobWIPTotal."Calc. Recog. Sales Amount" < 0 then
                InsertWarning(JobWIPTotal, StrSubstNo(Text003, JobWIPTotal.FieldCaption("Calc. Recog. Sales Amount")));

            if JobWIPTotal."Calc. Recog. Costs Amount" < 0 then
                InsertWarning(JobWIPTotal, StrSubstNo(Text003, JobWIPTotal.FieldCaption("Calc. Recog. Costs Amount")));
        end;
        OnAfterCreateEntries(JobWIPTotal, Contrato);
    end;

    procedure DeleteEntries(JobWIPTotal: Record "Contrato WIP Total")
    begin
        SetRange("Contrato WIP Total Entry No.", JobWIPTotal."Entry No.");
        if not IsEmpty() then
            DeleteAll(true);
    end;

    procedure InsertWarning(JobWIPTotal: Record "Contrato WIP Total"; Message: Text[250])
    begin
        Reset();
        if FindLast() then
            "Entry No." += 1
        else
            "Entry No." := 1;
        "Contrato WIP Total Entry No." := JobWIPTotal."Entry No.";
        "Contrato No." := JobWIPTotal."Contrato No.";
        "Contrato Task No." := JobWIPTotal."Contrato Task No.";
        "Warning Message" := Message;
        OnInsertWarningOnBeforeInsert(Rec);
        Insert();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateEntries(JobWIPTotal: Record "Contrato WIP Total"; Contrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateEntriesOnAfterCalcShouldInsertWarnings(JobWIPTotal: Record "Contrato WIP Total"; Contrato: Record Contrato; var ShouldInsertWarnings: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertWarningOnBeforeInsert(var JobWIPWarning: Record "Contrato WIP Warning")
    begin
    end;
}

