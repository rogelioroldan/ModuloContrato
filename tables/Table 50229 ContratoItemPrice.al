table 50229 "Contrato Item Price"
{
    Caption = 'contrato Item Price';

    DrillDownPageID = "Contrato Item Prices";
    LookupPageID = "Contrato Item Prices";
    //   
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Contrato No."; Code[20])
        {
            Caption = 'contrato No.';
            NotBlank = true;
            TableRelation = Contrato;

#if not CLEAN23
            trigger OnValidate()
            begin
                GetContrato();
                "Currency Code" := Contrato."Currency Code";
            end;
#endif
        }
        field(2; "Contrato Task No."; Code[20])
        {
            Caption = 'contrato Task No.';
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
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;

#if not CLEAN23
            trigger OnValidate()
            begin
                Item.Get("Item No.");
                Validate("Unit of Measure Code", Item."Sales Unit of Measure");
            end;
#endif
        }
        field(4; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
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
        field(9; Description; Text[100])
        {
            CalcFormula = lookup(Item.Description where("No." = field("Item No.")));
            Caption = 'Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(10; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));
        }
        field(11; "Apply Contrato Price"; Boolean)
        {
            Caption = 'Apply contrato Price';
            InitValue = true;
        }
        field(12; "Apply Contrato Discount"; Boolean)
        {
            Caption = 'Apply contrato Discount';
            InitValue = true;
        }
    }

    keys
    {
        key(Key1; "Contrato No.", "Contrato Task No.", "Item No.", "Variant Code", "Unit of Measure Code", "Currency Code")
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
        CheckItemNoNotEmpty();
    end;

    var
        Item: Record Item;
        Contrato: Record Contrato;
        JT: Record "Contrato Task";

    local procedure GetContrato()
    begin
        TestField("Contrato No.");
        Contrato.Get("Contrato No.");
    end;

    local procedure CheckItemNoNotEmpty()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckItemNoNotEmpty(Rec, IsHandled);
        if IsHandled then
            exit;

        TestField("Item No.");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckItemNoNotEmpty(var ContratoItemPrice: Record "Contrato Item Price"; var IsHandled: Boolean)
    begin
    end;
#endif
}

