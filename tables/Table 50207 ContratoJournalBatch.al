table 50207 "Contrato Journal Batch"
{
    Caption = 'contrato Journal Batch';
    DataCaptionFields = Name, Description;
    LookupPageID = "Contrato Journal Batches";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            NotBlank = true;
            TableRelation = "Contrato Journal Template";
        }
        field(2; Name; Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(4; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";

            trigger OnValidate()
            begin
                if "Reason Code" <> xRec."Reason Code" then begin
                    ContratoJnlLine.SetRange("Journal Template Name", "Journal Template Name");
                    ContratoJnlLine.SetRange("Journal Batch Name", Name);
                    ContratoJnlLine.ModifyAll("Reason Code", "Reason Code");
                    Modify();
                end;
            end;
        }
        field(5; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                if "No. Series" <> '' then begin
                    ContratoJnlTemplate.Get("Journal Template Name");
                    if ContratoJnlTemplate.Recurring then
                        Error(
                          Text000,
                          FieldCaption("Posting No. Series"));
                    if "No. Series" = "Posting No. Series" then
                        Validate("Posting No. Series", '');
                end;
            end;
        }
        field(6; "Posting No. Series"; Code[20])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                if ("Posting No. Series" = "No. Series") and ("Posting No. Series" <> '') then
                    FieldError("Posting No. Series", StrSubstNo(Text001, "Posting No. Series"));
                ContratoJnlLine.SetRange("Journal Template Name", "Journal Template Name");
                ContratoJnlLine.SetRange("Journal Batch Name", Name);
                ContratoJnlLine.ModifyAll("Posting No. Series", "Posting No. Series");
                Modify();
            end;
        }
        field(22; Recurring; Boolean)
        {
            CalcFormula = lookup("Contrato Journal Template".Recurring where(Name = field("Journal Template Name")));
            Caption = 'Recurring';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Journal Template Name", Name)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        ContratoJnlLine.SetRange("Journal Template Name", "Journal Template Name");
        ContratoJnlLine.SetRange("Journal Batch Name", Name);
        ContratoJnlLine.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        LockTable();
        ContratoJnlTemplate.Get("Journal Template Name");
    end;

    trigger OnRename()
    begin
        ContratoJnlLine.SetRange("Journal Template Name", xRec."Journal Template Name");
        ContratoJnlLine.SetRange("Journal Batch Name", xRec.Name);
        while ContratoJnlLine.FindFirst() do
            ContratoJnlLine.Rename("Journal Template Name", Name, ContratoJnlLine."Line No.");
    end;

    var
        ContratoJnlTemplate: Record "Contrato Journal Template";
        ContratoJnlLine: Record "Contrato Journal Line";

        Text000: Label 'Only the %1 field can be filled in on recurring journals.';
        Text001: Label 'must not be %1';

    procedure SetupNewBatch()
    begin
        ContratoJnlTemplate.Get("Journal Template Name");
        "No. Series" := ContratoJnlTemplate."No. Series";
        "Posting No. Series" := ContratoJnlTemplate."Posting No. Series";
        "Reason Code" := ContratoJnlTemplate."Reason Code";
    end;
}
