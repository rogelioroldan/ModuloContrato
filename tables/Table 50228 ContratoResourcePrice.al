table 50228 "Contrato Resource Price"
{
    Caption = 'Contrato Resource Price';
#if not CLEAN23
    DrillDownPageID = "Contrato Resource Prices";
    LookupPageID = "Contrato Resource Prices";
    //ObsoleteState = Pending;
    //ObsoleteTag = '16.0';
#else
    ObsoleteState = Removed;
    ObsoleteTag = '26.0';
#endif    
    //ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation: table Price List Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Contrato No."; Code[20])
        {
            Caption = 'Contrato No.';
            NotBlank = true;
            TableRelation = Contrato;

            trigger OnValidate()
            begin
                GetContrato();
                "Currency Code" := Contrato."Currency Code";
            end;
        }
        field(2; "Contrato Task No."; Code[20])
        {
            Caption = 'Contrato Task No.';
            TableRelation = "Contrato Task"."Contrato Task No." where("Contrato No." = field("Contrato No."));

            trigger OnValidate()
            begin
                LockTable();
                if "Contrato Task No." <> '' then begin
                    JT.Get("Contrato No.", "Contrato Task No.");
                    JT.TestField("Contrato Task Type", JT."Contrato Task Type"::Posting);
                end;
            end;
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Resource,Group(Resource),All';
            OptionMembers = Resource,"Group(Resource)",All;

            trigger OnValidate()
            begin
                if Type <> xRec.Type then begin
                    Code := '';
                    Description := '';
                end;
            end;
        }
        field(4; "Code"; Code[20])
        {
            Caption = 'Code';
            TableRelation = if (Type = const(Resource)) Resource
            else
            if (Type = const("Group(Resource)")) "Resource Group";

            trigger OnValidate()
            var
                Res: Record Resource;
                ResGrp: Record "Resource Group";
            begin
                if (Code <> '') and (Type = Type::All) then
                    Error(Text000, FieldCaption(Code), FieldCaption(Type), Type);
                case Type of
                    Type::Resource:
                        begin
                            Res.Get(Code);
                            Description := Res.Name;
                        end;
                    Type::"Group(Resource)":
                        begin
                            ResGrp.Get(Code);
                            "Work Type Code" := '';
                            Description := ResGrp.Name;
                        end;
                    Type::All:
                        begin
                            "Work Type Code" := '';
                            Description := '';
                        end;
                end;
            end;
        }
        field(5; "Work Type Code"; Code[10])
        {
            Caption = 'Work Type Code';
            TableRelation = "Work Type";
        }
        field(6; "Unit Price"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Price';

            trigger OnValidate()
            begin
                "Unit Cost Factor" := 0;
            end;
        }
        field(7; "Currency Code"; Code[10])
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
        field(8; "Unit Cost Factor"; Decimal)
        {
            Caption = 'Unit Cost Factor';

            trigger OnValidate()
            begin
                "Unit Price" := 0;
            end;
        }
        field(9; "Line Discount %"; Decimal)
        {
            Caption = 'Line Discount %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(11; "Apply Contrato Price"; Boolean)
        {
            Caption = 'Apply Contrato Price';
            InitValue = true;
        }
        field(12; "Apply Contrato Discount"; Boolean)
        {
            Caption = 'Apply Contrato Discount';
            InitValue = true;
        }
    }

    keys
    {
        key(Key1; "Contrato No.", "Contrato Task No.", Type, "Code", "Work Type Code", "Currency Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        LockTable();
        Contrato.Get("Contrato No.");
        if (Type = Type::Resource) and (Code = '') then
            FieldError(Code);
    end;

    trigger OnModify()
    begin
        if (Type = Type::Resource) and (Code = '') then
            FieldError(Code);
    end;

    var
        Contrato: Record Contrato;
        JT: Record "Contrato Task";

        Text000: Label '%1 cannot be specified when %2 is %3.';

    local procedure GetContrato()
    begin
        TestField("Contrato No.");
        Contrato.Get("Contrato No.");
    end;
}

