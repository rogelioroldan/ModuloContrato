table 50230 "Contrato G/L Account Price"
{
    Caption = 'Contrato G/L Account Price';
#if not CLEAN23
    DrillDownPageID = "Contrato G/L Account Prices";
    LookupPageID = "Contrato G/L Account Prices";
    ObsoleteState = Pending;
    ObsoleteTag = '16.0';
#else
    ObsoleteState = Removed;
    ObsoleteTag = '26.0';
#endif    
    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation: table Price List Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Contrato No."; Code[20])
        {
            Caption = 'Contrato No.';
            NotBlank = true;
            TableRelation = Contrato;

#if not CLEAN23
            trigger OnValidate()
            begin
                GetJob();
                "Currency Code" := Contrato."Currency Code";
            end;
#endif
        }
        field(2; "Contrato Task No."; Code[20])
        {
            Caption = 'Contrato Task No.';
            TableRelation = "Contrato Task"."Contrato Task No." where("Contrato No." = field("Contrato No."));

#if not CLEAN23
            trigger OnValidate()
            begin
                if "Contrato Task No." <> '' then begin
                    JT.Get("Contrato No.", "Contrato Task No.");
                    JT.TestField("Contrato Task Type", JT."Contrato Task Type"::Posting);
                end;
            end;
#endif
        }
        field(3; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            TableRelation = "G/L Account";
        }
        field(5; "Unit Price"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Price';

            trigger OnValidate()
            begin
                "Unit Cost Factor" := 0;
            end;
        }
        field(6; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;

            trigger OnValidate()
            begin
                if "Currency Code" <> xRec."Currency Code" then begin
                    "Unit Cost Factor" := 0;
                    "Line Discount %" := 0;
                    "Unit Price" := 0;
                end;
            end;
        }
        field(7; "Unit Cost Factor"; Decimal)
        {
            Caption = 'Unit Cost Factor';

            trigger OnValidate()
            begin
                "Unit Price" := 0;
            end;
        }
        field(8; "Line Discount %"; Decimal)
        {
            Caption = 'Line Discount %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(9; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
        }
        field(10; Description; Text[100])
        {
            CalcFormula = lookup("G/L Account".Name where("No." = field("G/L Account No.")));
            Caption = 'Description';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Contrato No.", "Contrato Task No.", "G/L Account No.", "Currency Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

#if not CLEAN23
    trigger OnInsert()
    begin
        LockTable();
        Contrato.Get("Contrato No.");
        CheckGLAccountNotEmpty();
    end;

    var
        Contrato: Record Contrato;
        JT: Record "Contrato Task";

    local procedure GetJob()
    begin
        TestField("Contrato No.");
        Contrato.Get("Contrato No.");
    end;

    local procedure CheckGLAccountNotEmpty()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckGLAccountNotEmpty(Rec, IsHandled);
        if IsHandled then
            exit;

        TestField("G/L Account No.");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckGLAccountNotEmpty(var JobGLAccountPrice: Record "Contrato G/L Account Price"; var IsHandled: Boolean)
    begin
    end;
#endif
}

