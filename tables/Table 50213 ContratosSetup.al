table 50213 "Contratos Setup"
{
    Caption = 'Contrato Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Contrato Nos."; Code[20])
        {
            Caption = 'Contrato Nos.';
            TableRelation = "No. Series";
        }
        field(3; "Apply Usage Link by Default"; Boolean)
        {
            Caption = 'Apply Usage Link by Default';
            InitValue = true;
        }
        field(4; "Default WIP Method"; Code[20])
        {
            Caption = 'Default WIP Method';
            TableRelation = "Contrato WIP Method".Code;
        }
        field(5; "Default Contrato Posting Group"; Code[20])
        {
            Caption = 'Default Project Posting Group';
            TableRelation = "Contrato Posting Group".Code;
        }
        field(6; "Default WIP Posting Method"; Option)
        {
            Caption = 'Default WIP Posting Method';
            OptionCaption = 'Per Project,Per Project Ledger Entry';
            OptionMembers = "Per Contrato","Per Contrato Ledger Entry";
        }
        field(7; "Allow Sched/Contract Lines Def"; Boolean)
        {
            Caption = 'Allow Sched/Contract Lines Def';
            InitValue = true;
        }
        field(9; "Document No. Is Contrato No."; Boolean)
        {
            Caption = 'Document No. Is Project No.';
            InitValue = true;
        }
        field(10; "Default Task Billing Method"; Enum "Task Billing Method")
        {
            Caption = 'Default Task Billing Method';
            DataClassification = CustomerContent;
        }
        field(31; "Logo Position on Documents"; Option)
        {
            Caption = 'Logo Position on Documents';
            OptionCaption = 'No Logo,Left,Center,Right';
            OptionMembers = "No Logo",Left,Center,Right;
        }
        field(40; "Contrato WIP Nos."; Code[20])
        {
            Caption = 'Project WIP Nos.';
            TableRelation = "No. Series";
        }
        field(50; "Archive Jobs"; Option)
        {
            Caption = 'Archive Projects';
            OptionCaption = 'Never,Question,Always';
            OptionMembers = Never,Question,Always;
            DataClassification = CustomerContent;
        }
        field(1001; "AutomaticUpdateContraItemCost"; Boolean)
        {
            AccessByPermission = TableData Item = R;
            Caption = 'Automatic Update Project Item Cost';
        }
        field(7000; "Price List Nos."; Code[20])
        {
            Caption = 'Price List Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(7003; "Default Sales Price List Code"; Code[20])
        {
            Caption = 'Default Sales Price List Code';
            TableRelation = "Price List Header" where("Price Type" = const(Sale), "Source Group" = const(Contrato), "Allow Updating Defaults" = const(true));
            DataClassification = CustomerContent;
            trigger OnLookup()
            var
                PriceListHeader: Record "Price List Header";
            begin
                if Page.RunModal(Page::"Sales Contrato Price Lists", PriceListHeader) = Action::LookupOK then begin
                    PriceListHeader.TestField("Allow Updating Defaults");
                    Validate("Default Sales Price List Code", PriceListHeader.Code);
                end;
            end;
#if not CLEAN23

            trigger OnValidate()
            var
                FeatureTelemetry: Codeunit "Feature Telemetry";
                PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
            begin
                if ("Default Sales Price List Code" <> xRec."Default Sales Price List Code") or (CurrFieldNo = 0) then
                    FeatureTelemetry.LogUptake('0000LLR', PriceCalculationMgt.GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::"Set up");
            end;
#endif
        }
        field(7004; "Default Purch Price List Code"; Code[20])
        {
            Caption = 'Default Purchase Price List Code';
            TableRelation = "Price List Header" where("Price Type" = const(Purchase), "Source Group" = const(Contrato), "Allow Updating Defaults" = const(true));
            DataClassification = CustomerContent;
            trigger OnLookup()
            var
                PriceListHeader: Record "Price List Header";
            begin
                if Page.RunModal(Page::"Purchase Contrato Price Lists", PriceListHeader) = Action::LookupOK then begin
                    PriceListHeader.TestField("Allow Updating Defaults");
                    Validate("Default Purch Price List Code", PriceListHeader.Code);
                end;
            end;
#if not CLEAN23

            trigger OnValidate()
            var
                FeatureTelemetry: Codeunit "Feature Telemetry";
                PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
            begin
                if ("Default Purch Price List Code" <> xRec."Default Purch Price List Code") or (CurrFieldNo = 0) then
                    FeatureTelemetry.LogUptake('0000LLR', PriceCalculationMgt.GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::"Set up");
            end;
#endif
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

