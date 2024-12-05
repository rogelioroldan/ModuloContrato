table 50202 "Contrato Task"
{
    Caption = 'Contrato Task';
    DrillDownPageID = "Contrato Task Lines";
    LookupPageID = "Contrato Task Lines";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Contrato No."; Code[20])
        {
            Caption = 'Project No.';
            Editable = false;
            NotBlank = true;
            TableRelation = Contrato;
        }
        field(2; "Contrato Task No."; Code[20])
        {
            Caption = 'Contrato Task No.';
            NotBlank = true;

            trigger OnValidate()
            var
                Contrato: Record Contrato;
                Customer: Record Customer;
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateJobTaskNo(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                if "Contrato Task No." = '' then
                    exit;
                Contrato.Get("Contrato No.");
                Contrato.TestField("Bill-to Customer No.");
                Customer.Get(Contrato."Bill-to Customer No.");
                "Contrato Posting Group" := Contrato."Contrato Posting Group";
            end;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(4; "Contrato Task Type"; Enum "Contrato Task Type")
        {
            Caption = 'Contrato Task Type';

            trigger OnValidate()
            begin
                if (xRec."Contrato Task Type" = "Contrato Task Type"::Posting) and
                   ("Contrato Task Type" <> "Contrato Task Type"::Posting)
                then begin
                    if JobLedgEntriesExist() or JobPlanningLinesExist() then
                        Error(CannotChangeAssociatedEntriesErr, FieldCaption("Contrato Task Type"), TableCaption);
                    ClearCustomerData();
                end;

                if "Contrato Task Type" <> "Contrato Task Type"::Posting then begin
                    "Contrato Posting Group" := '';
                    if "WIP-Total" = "WIP-Total"::Excluded then
                        "WIP-Total" := "WIP-Total"::" ";
                end;

                Totaling := '';

                if (xRec."Contrato Task Type" <> "Contrato Task Type"::Posting) and ("Contrato Task Type" = "Contrato Task Type"::Posting) then
                    InitCustomer();
            end;
        }
        field(6; "WIP-Total"; Option)
        {
            Caption = 'WIP-Total';
            OptionCaption = ' ,Total,Excluded';
            OptionMembers = " ",Total,Excluded;

            trigger OnValidate()
            var
                Contrato: Record Contrato;
            begin
                case "WIP-Total" of
                    "WIP-Total"::Total:
                        begin
                            Contrato.Get("Contrato No.");
                            "WIP Method" := Contrato."WIP Method";
                        end;
                    "WIP-Total"::Excluded:
                        begin
                            TestField("Contrato Task Type", "Contrato Task Type"::Posting);
                            "WIP Method" := ''
                        end;
                    else
                        "WIP Method" := ''
                end;
            end;
        }
        field(7; "Contrato Posting Group"; Code[20])
        {
            Caption = 'Contrato Posting Group';
            TableRelation = "Contrato Posting Group";

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateJobPostingGroup(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                if "Contrato Posting Group" <> '' then
                    TestField("Contrato Task Type", "Contrato Task Type"::Posting);
            end;
        }
        field(9; "WIP Method"; Code[20])
        {
            Caption = 'WIP Method';
            TableRelation = "Contrato WIP Method".Code where(Valid = const(true));

            trigger OnValidate()
            begin
                if "WIP Method" <> '' then
                    TestField("WIP-Total", "WIP-Total"::Total);
            end;
        }
        field(10; "Schedule (Total Cost)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Contrato Planning Line"."Total Cost (LCY)" where("Contrato No." = field("Contrato No."),
                                                                            "Contrato Task No." = field("Contrato Task No."),
                                                                            "Contrato Task No." = field(filter(Totaling)),
                                                                            "Schedule Line" = const(true),
                                                                            "Planning Date" = field("Planning Date Filter")));
            Caption = 'Budget (Total Cost)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Schedule (Total Price)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Contrato Planning Line"."Line Amount (LCY)" where("Contrato No." = field("Contrato No."),
                                                                             "Contrato Task No." = field("Contrato Task No."),
                                                                             "Contrato Task No." = field(filter(Totaling)),
                                                                             "Schedule Line" = const(true),
                                                                             "Planning Date" = field("Planning Date Filter")));
            Caption = 'Budget (Total Price)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(12; "Usage (Total Cost)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Contrato Ledger Entry"."Total Cost (LCY)" where("Contrato No." = field("Contrato No."),
                                                                           "Contrato Task No." = field("Contrato Task No."),
                                                                           "Contrato Task No." = field(filter(Totaling)),
                                                                           "Entry Type" = const(Usage),
                                                                           "Posting Date" = field("Posting Date Filter")));
            Caption = 'Actual (Total Cost)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; "Usage (Total Price)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Contrato Ledger Entry"."Line Amount (LCY)" where("Contrato No." = field("Contrato No."),
                                                                            "Contrato Task No." = field("Contrato Task No."),
                                                                            "Contrato Task No." = field(filter(Totaling)),
                                                                            "Entry Type" = const(Usage),
                                                                            "Posting Date" = field("Posting Date Filter")));
            Caption = 'Actual (Total Price)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Contract (Total Cost)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Contrato Planning Line"."Total Cost (LCY)" where("Contrato No." = field("Contrato No."),
                                                                            "Contrato Task No." = field("Contrato Task No."),
                                                                            "Contrato Task No." = field(filter(Totaling)),
                                                                            "Contract Line" = const(true),
                                                                            "Planning Date" = field("Planning Date Filter")));
            Caption = 'Billable (Total Cost)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "Contract (Total Price)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Contrato Planning Line"."Line Amount (LCY)" where("Contrato No." = field("Contrato No."),
                                                                             "Contrato Task No." = field("Contrato Task No."),
                                                                             "Contrato Task No." = field(filter(Totaling)),
                                                                             "Contract Line" = const(true),
                                                                             "Planning Date" = field("Planning Date Filter")));
            Caption = 'Billable (Total Price)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(16; "Contract (Invoiced Price)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = - sum("Contrato Ledger Entry"."Line Amount (LCY)" where("Contrato No." = field("Contrato No."),
                                                                             "Contrato Task No." = field("Contrato Task No."),
                                                                             "Contrato Task No." = field(filter(Totaling)),
                                                                             "Entry Type" = const(Sale),
                                                                             "Posting Date" = field("Posting Date Filter")));
            Caption = 'Invoiced (Total Price)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(17; "Contract (Invoiced Cost)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = - sum("Contrato Ledger Entry"."Total Cost (LCY)" where("Contrato No." = field("Contrato No."),
                                                                            "Contrato Task No." = field("Contrato Task No."),
                                                                            "Contrato Task No." = field(filter(Totaling)),
                                                                            "Entry Type" = const(Sale),
                                                                            "Posting Date" = field("Posting Date Filter")));
            Caption = 'Invoiced (Total Cost)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(19; "Posting Date Filter"; Date)
        {
            Caption = 'Posting Date Filter';
            FieldClass = FlowFilter;
        }
        field(20; "Planning Date Filter"; Date)
        {
            Caption = 'Planning Date Filter';
            FieldClass = FlowFilter;
        }
        field(21; Totaling; Text[250])
        {
            Caption = 'Totaling';
            TableRelation = "Contrato Task"."Contrato Task No." where("Contrato No." = field("Contrato No."));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                if Totaling <> '' then
                    if not ("Contrato Task Type" in ["Contrato Task Type"::Total, "Contrato Task Type"::"End-Total"]) then
                        FieldError("Contrato Task Type");
                Validate("WIP-Total");
                CalcFields(
                  "Schedule (Total Cost)",
                  "Schedule (Total Price)",
                  "Usage (Total Cost)",
                  "Usage (Total Price)",
                  "Contract (Total Cost)",
                  "Contract (Total Price)",
                  "Contract (Invoiced Price)",
                  "Contract (Invoiced Cost)");
            end;
        }
        field(22; "New Page"; Boolean)
        {
            Caption = 'New Page';
        }
        field(23; "No. of Blank Lines"; Integer)
        {
            BlankZero = true;
            Caption = 'No. of Blank Lines';
            MinValue = 0;
        }
        field(24; Indentation; Integer)
        {
            Caption = 'Indentation';
            MinValue = 0;
        }
        field(30; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location where("Use As In-Transit" = const(false));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Location Code" <> xRec."Location Code") then
                    MessageIfJobPlanningLineExist(FieldCaption("Location Code"));

                SetDefaultBin();
            end;
        }
        field(31; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = Bin.Code where("Location Code" = field("Location Code"));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Bin Code" <> xRec."Bin Code") then
                    MessageIfJobPlanningLineExist(FieldCaption("Bin Code"));
            end;
        }
        field(34; "Recognized Sales Amount"; Decimal)
        {
            BlankZero = true;
            Caption = 'Recognized Sales Amount';
            Editable = false;
        }
        field(37; "Recognized Costs Amount"; Decimal)
        {
            BlankZero = true;
            Caption = 'Recognized Costs Amount';
            Editable = false;
        }
        field(41; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language;
            DataClassification = CustomerContent;
        }
        field(56; "Recognized Sales G/L Amount"; Decimal)
        {
            BlankZero = true;
            Caption = 'Recognized Sales G/L Amount';
            Editable = false;
        }
        field(57; "Recognized Costs G/L Amount"; Decimal)
        {
            BlankZero = true;
            Caption = 'Recognized Costs G/L Amount';
            Editable = false;
        }
        field(60; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          Blocked = const(false));

            trigger OnValidate()
            begin
                Rec.ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(61; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));

            trigger OnValidate()
            begin
                Rec.ValidateShortcutDimCode(2, "Global Dimension 2 Code");
            end;
        }
        field(62; "Outstanding Orders"; Decimal)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            CalcFormula = sum("Purchase Line"."Outstanding Amt. Ex. VAT (LCY)" where("Document Type" = const(Order),
                                                                                      "Job No." = field("Contrato No."),
                                                                                      "Job Task No." = field("Contrato Task No."),
                                                                                      "Job Task No." = field(filter(Totaling))));
            Caption = 'Outstanding Orders';
            FieldClass = FlowField;
        }
        field(63; "Amt. Rcd. Not Invoiced"; Decimal)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            CalcFormula = sum("Purchase Line"."A. Rcd. Not Inv. Ex. VAT (LCY)" where("Document Type" = const(Order),
                                                                                      "Job No." = field("Contrato No."),
                                                                                      "Job Task No." = field("Contrato Task No."),
                                                                                      "Job Task No." = field(filter(Totaling))));
            Caption = 'Amt. Rcd. Not Invoiced';
            FieldClass = FlowField;
        }
        field(64; "Remaining (Total Cost)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Contrato Planning Line"."Remaining Total Cost (LCY)" where("Contrato No." = field("Contrato No."),
                                                                                      "Contrato Task No." = field("Contrato Task No."),
                                                                                      "Contrato Task No." = field(filter(Totaling)),
                                                                                      "Schedule Line" = const(true),
                                                                                      "Planning Date" = field("Planning Date Filter")));
            Caption = 'Remaining (Total Cost)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(65; "Remaining (Total Price)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Contrato Planning Line"."Remaining Line Amount (LCY)" where("Contrato No." = field("Contrato No."),
                                                                                       "Contrato Task No." = field("Contrato Task No."),
                                                                                       "Contrato Task No." = field(filter(Totaling)),
                                                                                       "Schedule Line" = const(true),
                                                                                       "Planning Date" = field("Planning Date Filter")));
            Caption = 'Remaining (Total Price)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(66; "Start Date"; Date)
        {
            CalcFormula = min("Contrato Planning Line"."Planning Date" where("Contrato No." = field("Contrato No."),
                                                                         "Contrato Task No." = field("Contrato Task No.")));
            Caption = 'Start Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(67; "End Date"; Date)
        {
            CalcFormula = max("Contrato Planning Line"."Planning Date" where("Contrato No." = field("Contrato No."),
                                                                         "Contrato Task No." = field("Contrato Task No.")));
            Caption = 'End Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(70; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            TableRelation = Customer;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Bill-to Customer No." <> '' then
                    TestField("Contrato Task Type", "Contrato Task Type"::Posting);

                //BillToCustomerNoUpdated(Rec, xRec);
            end;
        }
        field(71; "Bill-to Name"; Text[100])
        {
            Caption = 'Bill-to Name';
            TableRelation = Customer.Name;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                Customer: Record Customer;
            begin
                if "Bill-to Customer No." <> '' then
                    Customer.Get("Bill-to Customer No.");

                if Customer.SelectCustomer(Customer) then begin
                    xRec := Rec;
                    "Bill-to Name" := Customer.Name;
                    Validate("Bill-to Customer No.", Customer."No.");
                end;
            end;

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                if ShouldSearchForCustomerByName("Bill-to Customer No.") then
                    Validate("Bill-to Customer No.", Customer.GetCustNo("Bill-to Name"));
            end;
        }
        field(72; "Bill-to Address"; Text[100])
        {
            Caption = 'Bill-to Address';
            DataClassification = CustomerContent;
        }
        field(73; "Bill-to Address 2"; Text[50])
        {
            Caption = 'Bill-to Address 2';
            DataClassification = CustomerContent;
        }
        field(74; "Bill-to City"; Text[30])
        {
            Caption = 'Bill-to City';
            DataClassification = CustomerContent;
            TableRelation = if ("Bill-to Country/Region Code" = const('')) "Post Code".City
            else
            if ("Bill-to Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Bill-to Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
#pragma warning disable AA0139
                PostCode.LookupPostCode("Bill-to City", "Bill-to Post Code", "Bill-to County", "Bill-to Country/Region Code");
#pragma warning restore AA0139
            end;

            trigger OnValidate()
            var
            begin
                PostCode.ValidateCity(
                    "Bill-to City", "Bill-to Post Code", "Bill-to County", "Bill-to Country/Region Code",
                    (CurrFieldNo <> 0) and GuiAllowed() and (not GetHideValidationDialog()));
            end;
        }
        field(75; "Bill-to County"; Text[30])
        {
            CaptionClass = '5,3,' + "Bill-to Country/Region Code";
            Caption = 'Bill-to County';
            DataClassification = CustomerContent;
        }
        field(76; "Bill-to Post Code"; Code[20])
        {
            Caption = 'Bill-to Post Code';
            TableRelation = if ("Bill-to Country/Region Code" = const('')) "Post Code"
            else
            if ("Bill-to Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Bill-to Country/Region Code"));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
#pragma warning disable AA0139
                PostCode.LookupPostCode("Bill-to City", "Bill-to Post Code", "Bill-to County", "Bill-to Country/Region Code");
#pragma warning restore AA0139
            end;

            trigger OnValidate()
            begin
                PostCode.ValidatePostCode(
                    "Bill-to City", "Bill-to Post Code", "Bill-to County", "Bill-to Country/Region Code",
                    (CurrFieldNo <> 0) and GuiAllowed() and (not GetHideValidationDialog()));
            end;
        }
        field(77; "Bill-to Country/Region Code"; Code[10])
        {
            Caption = 'Bill-to Country/Region Code';
            Editable = true;
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
#pragma warning disable AA0139
                PostCode.CheckClearPostCodeCityCounty(
                  "Bill-to City", "Bill-to Post Code", "Bill-to County", "Bill-to Country/Region Code", xRec."Bill-to Country/Region Code");
#pragma warning restore AA0139
            end;
        }
        field(78; "Bill-to Name 2"; Text[50])
        {
            Caption = 'Bill-to Name 2';
            DataClassification = CustomerContent;
        }
        field(79; "Bill-to Contact No."; Code[20])
        {
            AccessByPermission = TableData Contact = R;
            Caption = 'Bill-to Contact No.';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                BilltoContactLookup();
            end;

            trigger OnValidate()
            begin
                if ("Bill-to Contact No." <> xRec."Bill-to Contact No.") and
                   (xRec."Bill-to Contact No." <> '')
                then
                    if ("Bill-to Contact No." = '') and ("Bill-to Customer No." = '') then begin
                        Init();
                        Validate(Description, xRec.Description);
                    end;

                if ("Bill-to Customer No." <> '') and ("Bill-to Contact No." <> '') then begin
                    Cont.Get("Bill-to Contact No.");
                    if ContBusinessRelation.FindByRelation(ContBusinessRelation."Link to Table"::Customer, "Bill-to Customer No.") then
                        if ContBusinessRelation."Contact No." <> Cont."Company No." then
                            Error(ContactBusRelDiffCompErr, Cont."No.", Cont.Name, "Bill-to Customer No.");
                end;
                UpdateBillToCust("Bill-to Contact No.");
            end;
        }
        field(80; "Bill-to Contact"; Text[100])
        {
            Caption = 'Bill-to Contact';
            DataClassification = CustomerContent;
        }
        field(90; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
            TableRelation = Customer;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Sell-to Customer No." <> '' then
                    TestField("Contrato Task Type", "Contrato Task Type"::Posting);

                //SellToCustomerNoUpdated(Rec, xRec);
            end;
        }
        field(91; "Sell-to Customer Name"; Text[100])
        {
            Caption = 'Sell-to Customer Name';
            TableRelation = Customer.Name;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                CustomerName: Text;
            begin
                CustomerName := "Sell-to Customer Name";
                LookupSellToCustomerName(CustomerName);
                "Sell-to Customer Name" := CopyStr(CustomerName, 1, MaxStrLen("Sell-to Customer Name"));
            end;

            trigger OnValidate()
            var
                Customer: Record Customer;
                LookupStateManager: Codeunit "Lookup State Manager";
            begin
                if LookupStateManager.IsRecordSaved() then
                    LookupStateManager.ClearSavedRecord();

                if LookupStateManager.IsRecordSaved() then begin
                    Customer := LookupStateManager.GetSavedRecord();
                    if Customer."No." <> '' then begin
                        LookupStateManager.ClearSavedRecord();
                        Validate("Sell-to Customer No.", Customer."No.");

                        exit;
                    end;
                end;

                if ShouldSearchForCustomerByName("Sell-to Customer No.") then
                    Validate("Sell-to Customer No.", Customer.GetCustNo("Sell-to Customer Name"));
            end;
        }
        field(92; "Sell-to Customer Name 2"; Text[50])
        {
            Caption = 'Sell-to Customer Name 2';
            DataClassification = CustomerContent;
        }
        field(93; "Sell-to Address"; Text[100])
        {
            Caption = 'Sell-to Address';
            DataClassification = CustomerContent;
        }
        field(94; "Sell-to Address 2"; Text[50])
        {
            Caption = 'Sell-to Address 2';
            DataClassification = CustomerContent;
        }
        field(95; "Sell-to City"; Text[30])
        {
            Caption = 'Sell-to City';
            TableRelation = if ("Sell-to Country/Region Code" = const('')) "Post Code".City
            else
            if ("Sell-to Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Sell-to Country/Region Code"));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
#pragma warning disable AA0139
                PostCode.LookupPostCode("Sell-to City", "Sell-to Post Code", "Sell-to County", "Sell-to Country/Region Code");
#pragma warning restore AA0139
            end;

            trigger OnValidate()
            begin
                PostCode.ValidateCity(
                    "Sell-to City", "Sell-to Post Code", "Sell-to County", "Sell-to Country/Region Code",
                    (CurrFieldNo <> 0) and GuiAllowed() and (not GetHideValidationDialog()));
            end;
        }
        field(96; "Sell-to Contact"; Text[100])
        {
            Caption = 'Sell-to Contact';
            DataClassification = CustomerContent;
        }
        field(97; "Sell-to Post Code"; Code[20])
        {
            Caption = 'Sell-to Post Code';
            TableRelation = if ("Sell-to Country/Region Code" = const('')) "Post Code"
            else
            if ("Sell-to Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Sell-to Country/Region Code"));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(98; "Sell-to County"; Text[30])
        {
            CaptionClass = '5,2,' + "Sell-to Country/Region Code";
            Caption = 'Sell-to County';
            DataClassification = CustomerContent;
        }
        field(99; "Sell-to Country/Region Code"; Code[10])
        {
            Caption = 'Sell-to Country/Region Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }
        field(100; "Sell-to Contact No."; Code[20])
        {
            Caption = 'Sell-to Contact No.';
            TableRelation = Contact;
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                SelltoContactLookup();
            end;

            trigger OnValidate()
            var
                Contact: Record Contact;
                ContactBusinessRelation: Record "Contact Business Relation";
            begin
                if ("Sell-to Contact No." <> xRec."Sell-to Contact No.") and
                   (xRec."Sell-to Contact No." <> '')
                then
                    if ("Sell-to Contact No." = '') and ("Sell-to Customer No." = '') then begin
                        Init();
                        Validate(Description, xRec.Description);
                    end;

                if ("Sell-to Customer No." <> '') and ("Sell-to Contact No." <> '') then begin
                    Contact.SetLoadFields(Name, "Company No.");
                    Contact.Get("Sell-to Contact No.");
                    if ContactBusinessRelation.FindByRelation(ContactBusinessRelation."Link to Table"::Customer, "Sell-to Customer No.") then
                        if ContactBusinessRelation."Contact No." <> Contact."Company No." then
                            Error(ContactBusRelDiffCompErr, Contact."No.", Contact.Name, "Sell-to Customer No.");
                end;
                if ("Sell-to Contact No." <> xRec."Sell-to Contact No.") then
                    UpdateSellToCust("Sell-to Contact No.");

                UpdateShipToContact();
            end;
        }
        field(110; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            TableRelation = "Ship-to Address".Code where("Customer No." = field("Sell-to Customer No."));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ShipToCodeValidate();
            end;
        }
        field(111; "Ship-to Name"; Text[100])
        {
            Caption = 'Ship-to Name';
            DataClassification = CustomerContent;
        }
        field(112; "Ship-to Name 2"; Text[50])
        {
            Caption = 'Ship-to Name 2';
            DataClassification = CustomerContent;
        }
        field(113; "Ship-to Address"; Text[100])
        {
            Caption = 'Ship-to Address';
            DataClassification = CustomerContent;
        }
        field(114; "Ship-to Address 2"; Text[50])
        {
            Caption = 'Ship-to Address 2';
            DataClassification = CustomerContent;
        }
        field(115; "Ship-to City"; Text[30])
        {
            Caption = 'Ship-to City';
            TableRelation = if ("Ship-to Country/Region Code" = const('')) "Post Code".City
            else
            if ("Ship-to Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Ship-to Country/Region Code"));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
#pragma warning disable AA0139
                PostCode.LookupPostCode("Ship-to City", "Ship-to Post Code", "Ship-to County", "Ship-to Country/Region Code");
#pragma warning restore AA0139
            end;

            trigger OnValidate()
            begin
                PostCode.ValidateCity(
                    "Ship-to City", "Ship-to Post Code", "Ship-to County", "Ship-to Country/Region Code",
                    (CurrFieldNo <> 0) and GuiAllowed() and (not GetHideValidationDialog()));
            end;
        }
        field(116; "Ship-to Contact"; Text[100])
        {
            Caption = 'Ship-to Contact';
            DataClassification = CustomerContent;
        }
        field(117; "Ship-to Post Code"; Code[20])
        {
            Caption = 'Ship-to Post Code';
            TableRelation = if ("Ship-to Country/Region Code" = const('')) "Post Code"
            else
            if ("Ship-to Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Ship-to Country/Region Code"));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                PostCode.ValidatePostCode(
                    "Ship-to City", "Ship-to Post Code", "Ship-to County", "Ship-to Country/Region Code",
                    (CurrFieldNo <> 0) and GuiAllowed() and (not GetHideValidationDialog()));
            end;
        }
        field(118; "Ship-to County"; Text[30])
        {
            CaptionClass = '5,4,' + "Ship-to Country/Region Code";
            Caption = 'Ship-to County';
            DataClassification = CustomerContent;
        }
        field(119; "Ship-to Country/Region Code"; Code[10])
        {
            Caption = 'Ship-to Country/Region Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }
        field(130; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "External Document No." <> '' then
                    TestField("Contrato Task Type", "Contrato Task Type"::Posting);
            end;
        }
        field(131; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
            DataClassification = CustomerContent;
        }
        field(132; "Payment Terms Code"; Code[10])
        {
            Caption = 'Payment Terms Code';
            TableRelation = "Payment Terms";
            DataClassification = CustomerContent;
        }
        field(133; "Your Reference"; Text[35])
        {
            Caption = 'Your Reference';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Your Reference" <> '' then
                    TestField("Contrato Task Type", "Contrato Task Type"::Posting);
            end;
        }
        field(134; "Price Calculation Method"; Enum "Price Calculation Method")
        {
            Caption = 'Price Calculation Method';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
                PriceType: Enum "Price Type";
            begin
                if "Price Calculation Method" <> "Price Calculation Method"::" " then
                    PriceCalculationMgt.VerifyMethodImplemented("Price Calculation Method", PriceType::Sale);
            end;
        }
        field(140; "Invoice Currency Code"; Code[10])
        {
            Caption = 'Invoice Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(721; "Coupled to Dataverse"; Boolean)
        {
            FieldClass = FlowField;
            Caption = 'Coupled to Field Service';
            Editable = false;
            CalcFormula = exist("CRM Integration Record" where("Integration ID" = field(SystemId), "Table ID" = const(Database::"Contrato Task")));
            ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
#if not CLEAN25
            ObsoleteState = Pending;
            ObsoleteTag = '25.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '28.0';
#endif
        }
    }

    keys
    {
        key(Key1; "Contrato No.", "Contrato Task No.")
        {
            Clustered = true;
        }
        key(Key2; "Contrato Task No.")
        {
        }
        key(Key3; SystemCreatedAt)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Contrato No.", "Contrato Task No.", Description, "Contrato Task Type")
        {
        }
        fieldgroup(Brick; "Contrato Task No.", Description)
        {
        }
    }

    trigger OnDelete()
    var
        JobPlanningLine: Record "Contrato Planning Line";
        JobWIPTotal: Record "Contrato WIP Total";
        JobTaskDim: Record "Contrato Task Dimension";
    begin
        if JobLedgEntriesExist() then
            Error(CannotDeleteAssociatedEntriesErr, TableCaption);

        JobPlanningLine.SetCurrentKey("Contrato No.", "Contrato Task No.");
        JobPlanningLine.SetRange("Contrato No.", "Contrato No.");
        JobPlanningLine.SetRange("Contrato Task No.", "Contrato Task No.");
        if CalledFromHeader then
            JobPlanningLine.SuspendDeletionCheck(true);
        JobPlanningLine.DeleteAll(true);

        //JobWIPTotal.DeleteEntriesForJobTask(Rec);

        JobTaskDim.SetRange("Contrato No.", "Contrato No.");
        JobTaskDim.SetRange("Contrato Task No.", "Contrato Task No.");
        if not JobTaskDim.IsEmpty() then
            JobTaskDim.DeleteAll();

        CalcFields("Schedule (Total Cost)", "Usage (Total Cost)");
        Contrato.UpdateOverBudgetValue("Contrato No.", true, "Usage (Total Cost)");
        Contrato.UpdateOverBudgetValue("Contrato No.", false, "Schedule (Total Cost)");
    end;

    trigger OnInsert()
    var
        Contrato: Record Contrato;
        Customer: Record Customer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOnInsert(Rec, IsHandled);
        if IsHandled then
            exit;

        LockTable();
        Contrato.Get("Contrato No.");
        // if Contrato.Blocked = Contrato.Blocked::All then
        //     Contrato.TestBlocked();
        Contrato.TestField("Bill-to Customer No.");
        Customer.Get(Contrato."Bill-to Customer No.");

        DimMgt.InsertJobTaskDim("Contrato No.", "Contrato Task No.", "Global Dimension 1 Code", "Global Dimension 2 Code");

        InitCustomer();
        InitLocation(Contrato);

        CalcFields("Schedule (Total Cost)", "Usage (Total Cost)");
        Contrato.UpdateOverBudgetValue("Contrato No.", true, "Usage (Total Cost)");
        Contrato.UpdateOverBudgetValue("Contrato No.", false, "Schedule (Total Cost)");

        OnAfterOnInsert(Rec, xRec);
    end;

    trigger OnModify()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOnModify(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        CalcFields("Schedule (Total Cost)", "Usage (Total Cost)");
        Contrato.UpdateOverBudgetValue("Contrato No.", true, "Usage (Total Cost)");
        Contrato.UpdateOverBudgetValue("Contrato No.", false, "Schedule (Total Cost)");
    end;

    var
        Contrato: Record Contrato;
        Location: Record Location;
        PostCode: Record "Post Code";
        Cust: Record Customer;
        Cont: Record Contact;
        ContBusinessRelation: Record "Contact Business Relation";
        DimMgt: Codeunit DimensionManagement;
        HideValidationDialog: Boolean;
        CalledFromHeader: Boolean;

        CannotDeleteAssociatedEntriesErr: Label 'You cannot delete %1 because one or more entries are associated.', Comment = '%1=The project task table name.';
        CannotChangeAssociatedEntriesErr: Label 'You cannot change %1 because one or more entries are associated with this %2.', Comment = '%1 = The field name you are trying to change; %2 = The project task table name.';
        PlanningLinesNotUpdatedMsg: Label 'You have changed %1 on the project task, but it has not been changed on the existing project planning lines.', Comment = '%1 = a Field Caption like Location Code';
        AssociatedEntriesExistErr: Label 'You cannot change %1 because one or more entries are associated with this %2.', Comment = '%1 = Name of field used in the error; %2 = The name of the Project Task table';
        ContactBusRelErr: Label 'Contact %1 %2 is not related to customer %3.', Comment = '%1 = The contact number; %2 = The contact''s name; %3 = The Bill-To Customer Number associated with this job task';
        ContactBusRelMissingErr: Label 'Contact %1 %2 is not related to a customer.', Comment = '%1 = The contact number; %2 = The contact''s name';
        ContactBusRelDiffCompErr: Label 'Contact %1 %2 is related to a different company than customer %3.', Comment = '%1 = The contact number; %2 = The contact''s name; %3 = The Bill-To Customer Number associated with this job task';
        UpdatePlanningLinesManuallyMsg: Label 'You must update the existing project planning lines manually.';
        SplitMessageTxt: Label '%1\%2', Comment = 'Some message text 1.\Some message text 2.', Locked = true;
        ConfirmChangeQst: Label 'Do you want to change %1?', Comment = '%1 = a Field Caption like Currency Code';
        BillToCustomerTxt: Label 'Bill-to Customer';
        SellToCustomerTxt: Label 'Sell-to Customer';
        UpdateCostPricesOnRelatedLinesQst: Label 'You have changed a customer. Prices and costs needs to be updated on a related lines.\\Do you want to update related lines?';

    procedure CalcEACTotalCost(): Decimal
    begin
        if "Contrato No." <> Contrato."No." then
            if not Contrato.Get("Contrato No.") then
                exit(0);

        if Contrato."Apply Usage Link" then
            exit("Usage (Total Cost)" + "Remaining (Total Cost)");

        exit(0);
    end;

    procedure CalcEACTotalPrice(): Decimal
    begin
        if "Contrato No." <> Contrato."No." then
            if not Contrato.Get("Contrato No.") then
                exit(0);

        if Contrato."Apply Usage Link" then
            exit("Usage (Total Price)" + "Remaining (Total Price)");

        exit(0);
    end;

    local procedure JobLedgEntriesExist(): Boolean
    var
        JobLedgEntry: Record "Contrato Ledger Entry";
    begin
        JobLedgEntry.SetCurrentKey("Contrato No.", "Contrato Task No.");
        JobLedgEntry.SetRange("Contrato No.", "Contrato No.");
        JobLedgEntry.SetRange("Contrato Task No.", "Contrato Task No.");
        //OnJobLedgEntriesExistOnAfterSetFilter(Rec, JobLedgEntry);
        exit(JobLedgEntry.FindFirst());
    end;

    local procedure JobPlanningLinesExist(): Boolean
    var
        JobPlanningLine: Record "Contrato Planning Line";
    begin
        JobPlanningLine.SetCurrentKey("Contrato No.", "Contrato Task No.");
        JobPlanningLine.SetRange("Contrato No.", "Contrato No.");
        JobPlanningLine.SetRange("Contrato Task No.", "Contrato Task No.");
        exit(JobPlanningLine.FindFirst());
    end;

    procedure Caption(): Text
    var
        Contrato: Record Contrato;
        Result: Text;
        IsHandled: Boolean;
    begin
        Result := '';
        IsHandled := false;
        //OnBeforeCaption(Rec, IsHandled, Result);
        if IsHandled then
            exit(Result);

        if not Contrato.Get("Contrato No.") then
            exit('');
        exit(StrSubstNo('%1 %2 %3 %4',
            Contrato."No.",
            Contrato.Description,
            "Contrato Task No.",
            Description));
    end;

    procedure InitWIPFields()
    var
        JobWIPTotal: Record "Contrato WIP Total";
    begin
        JobWIPTotal.SetRange("Contrato No.", "Contrato No.");
        JobWIPTotal.SetRange("Contrato Task No.", "Contrato Task No.");
        JobWIPTotal.SetRange("Posted to G/L", false);
        JobWIPTotal.DeleteAll(true);

        "Recognized Sales Amount" := 0;
        "Recognized Costs Amount" := 0;

        //OnInitWIPFieldsOnBeforeModify(Rec);
        Modify();
    end;

    procedure ToPriceSource(var PriceSource: Record "Price Source"; PriceType: Enum "Price Type")
    begin
        PriceSource.Init();
        PriceSource."Price Type" := PriceType;
        PriceSource.Validate("Source Type", PriceSource."Source Type"::"Contrato Task");
        PriceSource.Validate("Parent Source No.", "Contrato No.");
        PriceSource.Validate("Source No.", "Contrato Task No.");
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        JobTask2: Record "Contrato Task";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode, JobTask2, IsHandled);
        if not IsHandled then begin
            DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
            if JobTask2.Get("Contrato No.", "Contrato Task No.") then begin
                DimMgt.SaveJobTaskDim("Contrato No.", "Contrato Task No.", FieldNumber, ShortcutDimCode);
                Modify();
            end else
                DimMgt.SaveJobTaskTempDim(FieldNumber, ShortcutDimCode);
        end;

        OnAfterValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);
    end;

    procedure ClearTempDim()
    begin
        DimMgt.DeleteJobTaskTempDim();
    end;

    procedure ApplyPurchaseLineFilters(var PurchLine: Record "Purchase Line"; JobNo: Code[20]; JobTaskNo: Code[20])
    begin
        PurchLine.SetCurrentKey("Document Type", "Job No.", "Job Task No.");
        PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
        PurchLine.SetRange("Job No.", JobNo);
        if "Contrato Task Type" in ["Contrato Task Type"::Total, "Contrato Task Type"::"End-Total"] then
            PurchLine.SetFilter("Job Task No.", Totaling)
        else
            PurchLine.SetRange("Job Task No.", JobTaskNo);
        OnAfterApplyPurchaseLineFilters(Rec, PurchLine);
    end;

    local procedure SetDefaultBin()
    begin
        "Bin Code" := '';

        if "Location Code" = '' then
            exit;

        GetLocation("Location Code");
        if not Location."Bin Mandatory" or Location."Directed Put-away and Pick" then
            exit;

        if Location."To-Job Bin Code" <> '' then
            "Bin Code" := Location."To-Job Bin Code";
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if Location.Code <> LocationCode then
            Location.Get(LocationCode);
    end;

    local procedure MessageIfJobPlanningLineExist(ChangedFieldName: Text[100])
    var
        MessageText: Text;
    begin
        if JobPlanningLineExist() then begin
            MessageText := StrSubstNo(PlanningLinesNotUpdatedMsg, ChangedFieldName);
            MessageText := StrSubstNo(SplitMessageTxt, MessageText, UpdatePlanningLinesManuallyMsg);
            Message(MessageText);
        end;
    end;

    procedure JobPlanningLineExist(): Boolean
    var
        JobPlanningLine: Record "Contrato Planning Line";
    begin
        JobPlanningLine.SetRange("Contrato No.", "Contrato No.");
        JobPlanningLine.SetRange("Contrato Task No.", "Contrato Task No.");
        JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Item);
        exit(not JobPlanningLine.IsEmpty());
    end;

    procedure SalesJobLedgEntryExist() Result: Boolean
    var
        JobLedgEntry: Record "Contrato Ledger Entry";
    begin
        JobLedgEntry.SetCurrentKey("Contrato No.", "Contrato Task No.", "Entry Type", "Posting Date");
        JobLedgEntry.SetRange("Contrato No.", "Contrato No.");
        JobLedgEntry.SetRange("Contrato Task No.", "Contrato Task No.");
        JobLedgEntry.SetRange("Entry Type", JobLedgEntry."Entry Type"::Sale);
        Result := not JobLedgEntry.IsEmpty();
    end;

    procedure SalesLineExist() Result: Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        if "Contrato No." = '' then
            exit(false);

        SalesLine.SetCurrentKey("Job No.");
        SalesLine.SetRange("Job No.", "Contrato No.");
        Result := not SalesLine.IsEmpty();
    end;

    local procedure InitLocation(Contrato: Record Contrato)
    begin
        "Location Code" := Contrato."Location Code";
        "Bin Code" := Contrato."Bin Code";
    end;

    local procedure InitCustomer()
    begin
        if not Contrato.Get("Contrato No.") then
            exit;

        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
            exit;

        if "Contrato Task Type" <> "Contrato Task Type"::Posting then
            exit;

        SetHideValidationDialog(true);
        if Contrato."Sell-to Customer No." <> '' then
            Validate("Sell-to Customer No.", Contrato."Sell-to Customer No.");

        if (Contrato."Sell-to Customer No." <> Contrato."Bill-to Customer No.") and (Contrato."Bill-to Customer No." <> '') then
            Validate("Bill-to Customer No.", Contrato."Bill-to Customer No.");
    end;

    local procedure ClearCustomerData()
    begin
        if not Contrato.Get("Contrato No.") then
            exit;
        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
            exit;

        SetHideValidationDialog(true);
        if "Sell-to Customer No." <> '' then
            Validate("Sell-to Customer No.", '');

        if ("Sell-to Customer No." <> "Bill-to Customer No.") and ("Bill-to Customer No." <> '') then
            Validate("Bill-to Customer No.", '');
    end;

    local procedure BillToCustomerNoUpdated(var JobTask: Record "Contrato Task"; var xJobTask: Record "Contrato Task")
    var
        BillToCustomer: Record Customer;
    begin
        CheckBillToCustomerAssosEntriesExist(JobTask, xJobTask);

        if (xJobTask."Bill-to Customer No." <> '') and (not GetHideValidationDialog()) and GuiAllowed() then
            if not Confirm(ConfirmChangeQst, false, BillToCustomerTxt) then begin
                JobTask."Bill-to Customer No." := xJobTask."Bill-to Customer No.";
                JobTask."Bill-to Name" := xJobTask."Bill-to Name";
                exit;
            end;

        // Set sell-to first if it hasn't been set yet.
        if (JobTask."Sell-to Customer No." = '') and (JobTask."Bill-to Customer No." <> '') then
            Validate("Sell-to Customer No.", JobTask."Bill-to Customer No.");

        if JobTask."Bill-to Customer No." <> '' then begin
            BillToCustomer.Get(JobTask."Bill-to Customer No.");
            JobTask."Bill-to Name" := BillToCustomer.Name;
            JobTask."Bill-to Name 2" := BillToCustomer."Name 2";
            JobTask."Bill-to Address" := BillToCustomer.Address;
            JobTask."Bill-to Address 2" := BillToCustomer."Address 2";
            JobTask."Bill-to City" := BillToCustomer.City;
            JobTask."Bill-to Post Code" := BillToCustomer."Post Code";
            JobTask."Bill-to County" := BillToCustomer.County;
            JobTask."Bill-to Country/Region Code" := BillToCustomer."Country/Region Code";
            JobTask."Payment Method Code" := BillToCustomer."Payment Method Code";
            JobTask."Payment Terms Code" := BillToCustomer."Payment Terms Code";

            Contrato.Get("Contrato No.");
            if Contrato."Bill-to Customer No." = BillToCustomer."No." then
                "Invoice Currency Code" := Contrato."Invoice Currency Code"
            else
                "Invoice Currency Code" := BillToCustomer."Currency Code";

            JobTask."Language Code" := BillToCustomer."Language Code";
            GetCustomerContact(JobTask."Bill-to Customer No.", JobTask."Bill-to Contact No.", JobTask."Bill-to Contact");
            CreateDefaultJobTaskDimensionsFromCustomer(JobTask."Bill-to Customer No.");
        end else begin
            JobTask."Bill-to Name" := '';
            JobTask."Bill-to Name 2" := '';
            JobTask."Bill-to Address" := '';
            JobTask."Bill-to Address 2" := '';
            JobTask."Bill-to City" := '';
            JobTask."Bill-to Post Code" := '';
            JobTask."Bill-to County" := '';
            JobTask."Bill-to Country/Region Code" := '';
            JobTask."Language Code" := '';
            JobTask."Bill-to Contact" := '';
            JobTask."Bill-to Contact No." := '';
            JobTask."Payment Method Code" := '';
            JobTask."Payment Terms Code" := '';
        end;

        if (xJobTask."Bill-to Customer No." <> '') and (JobTask."Bill-to Customer No." <> xJobTask."Bill-to Customer No.") then
            UpdateCostPricesOnRelatedJobPlanningLines(JobTask);
    end;

    local procedure UpdateCostPricesOnRelatedJobPlanningLines(var JobTask: Record "Contrato Task")
    var
        JobPlanningLine: Record "Contrato Planning Line";
        ConfirmManagement: Codeunit "Confirm Management";
        ConfirmResult: Boolean;
        IsHandled: Boolean;
    begin
        JobPlanningLine.SetRange("Contrato No.", JobTask."Contrato No.");
        JobPlanningLine.SetRange("Contrato Task No.", JobTask."Contrato Task No.");
        JobPlanningLine.SetFilter(Type, '<>%1', JobPlanningLine.Type::Text);
        JobPlanningLine.SetFilter("No.", '<>%1', '');
        if JobPlanningLine.IsEmpty() then
            exit;

        IsHandled := false;
        OnUpdateCostPricesOnRelatedJobPlanningLinesOnBeforeConfirmUpdate(JobTask, ConfirmResult, IsHandled);
        if not IsHandled then
            ConfirmResult := ConfirmManagement.GetResponseOrDefault(UpdateCostPricesOnRelatedLinesQst, true);
        if not ConfirmResult then
            exit;

        JobTask.Modify(true);
        JobPlanningLine.FindSet(true);
        repeat
            JobPlanningLine."Line Amount" := 0;
            JobPlanningLine.UpdateAllAmounts();
            JobPlanningLine.Modify(true);
        until JobPlanningLine.Next() = 0;
    end;

    local procedure CreateDefaultJobTaskDimensionsFromCustomer(BillToCustomerNo: Code[20])
    var
        JobTaskDim: Record "Contrato Task Dimension";
        CustDefaultDimension: Record "Default Dimension";
        TempJobDefaultDimension: Record "Default Dimension" temporary;
    begin
        JobTaskDim.SetRange("Contrato No.", "Contrato No.");
        JobTaskDim.SetRange("Contrato Task No.", "Contrato Task No.");
        if not JobTaskDim.IsEmpty() then
            JobTaskDim.DeleteAll();

        CustDefaultDimension.SetRange("Table ID", DATABASE::Customer);
        CustDefaultDimension.SetRange("No.", BillToCustomerNo);
        if CustDefaultDimension.FindSet() then
            repeat
                TempJobDefaultDimension.Init();
                TempJobDefaultDimension.TransferFields(CustDefaultDimension);
                TempJobDefaultDimension."Table ID" := Database::"Contrato Task";
                TempJobDefaultDimension."No." := "Contrato Task No.";
                TempJobDefaultDimension.Insert();
            until CustDefaultDimension.Next() = 0;

        DimMgt.InsertJobTaskDim(TempJobDefaultDimension, "Contrato No.", "Contrato Task No.", "Global Dimension 1 Code", "Global Dimension 2 Code");
    end;

    procedure ShouldSearchForCustomerByName(CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
    begin
        if CustomerNo = '' then
            exit(true);

        if not Customer.Get(CustomerNo) then
            exit(true);

        exit(not Customer."Disable Search by Name");
    end;

    local procedure SellToCustomerNoUpdated(var JobTask: Record "Contrato Task"; var xJobTask: Record "Contrato Task")
    var
        SellToCustomer: Record Customer;
    begin
        if JobTask."Sell-to Customer No." <> '' then begin
            SellToCustomer.Get(JobTask."Sell-to Customer No.");
            SellToCustomer.CheckBlockedCustOnDocs(SellToCustomer, Enum::"Sales Document Type"::Order, false, false);
        end;

        CheckSellToCustomerAssosEntriesExist(JobTask, xJobTask);

        if (xJobTask."Sell-to Customer No." <> '') and (not GetHideValidationDialog()) and GuiAllowed() then
            if not Confirm(ConfirmChangeQst, false, SellToCustomerTxt) then begin
                JobTask."Sell-to Customer No." := xJobTask."Sell-to Customer No.";
                JobTask."Sell-to Customer Name" := xJobTask."Sell-to Customer Name";
                exit;
            end;

        if JobTask."Sell-to Customer No." <> '' then begin
            SellToCustomer.Get(JobTask."Sell-to Customer No.");
            JobTask."Sell-to Customer Name" := SellToCustomer.Name;
            JobTask."Sell-to Customer Name 2" := SellToCustomer."Name 2";
            JobTask."Sell-to Address" := SellToCustomer.Address;
            JobTask."Sell-to Address 2" := SellToCustomer."Address 2";
            JobTask."Sell-to City" := SellToCustomer.City;
            JobTask."Sell-to Post Code" := SellToCustomer."Post Code";
            JobTask."Sell-to County" := SellToCustomer.County;
            JobTask."Sell-to Country/Region Code" := SellToCustomer."Country/Region Code";
            UpdateSellToContact(JobTask."Sell-to Customer No.");
        end else begin
            JobTask."Sell-to Customer Name" := '';
            JobTask."Sell-to Customer Name 2" := '';
            JobTask."Sell-to Address" := '';
            JobTask."Sell-to Address 2" := '';
            JobTask."Sell-to City" := '';
            JobTask."Sell-to Post Code" := '';
            JobTask."Sell-to County" := '';
            JobTask."Sell-to Country/Region Code" := '';
            JobTask."Sell-to Contact" := '';
            JobTask."Sell-to Contact No." := '';
        end;

        if SellToCustomer."Bill-to Customer No." <> '' then
            JobTask.Validate("Bill-to Customer No.", SellToCustomer."Bill-to Customer No.")
        else
            JobTask.Validate("Bill-to Customer No.", Rec."Sell-to Customer No.");

        if
            (xJobTask.ShipToNameEqualsSellToName() and xJobTask.ShipToAddressEqualsSellToAddress()) or
            ((xJobTask."Ship-to Code" <> '') and (xJobTask."Sell-to Customer No." <> JobTask."Sell-to Customer No."))
        then
            JobTask.SyncShipToWithSellTo();
    end;

    protected procedure UpdateSellToContact(CustomerNo: Code[20])
    begin
        GetCustomerContact(CustomerNo, Rec."Sell-to Contact No.", Rec."Sell-to Contact");
    end;

    local procedure GetCustomerContact(CustomerNo: Code[20]; var ContactNo: Code[20]; var Contact: Text[100])
    var
        ContBusRel: Record "Contact Business Relation";
    begin
        if Cust.Get(CustomerNo) then begin
            if Cust."Primary Contact No." <> '' then
                ContactNo := Cust."Primary Contact No."
            else begin
                ContBusRel.Reset();
                ContBusRel.SetCurrentKey("Link to Table", "No.");
                ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
                ContBusRel.SetRange("No.", CustomerNo);
                if ContBusRel.FindFirst() then
                    ContactNo := ContBusRel."Contact No.";
            end;
            Contact := Cust.Contact;
        end;
    end;

    local procedure CheckBillToCustomerAssosEntriesExist(var JobTask: Record "Contrato Task"; var xJobTask: Record "Contrato Task")
    begin
        if (JobTask."Bill-to Customer No." = '') or (JobTask."Bill-to Customer No." <> xJobTask."Bill-to Customer No.") then begin
            if JobTask.SalesJobLedgEntryExist() then
                Error(AssociatedEntriesExistErr, JobTask.FieldCaption("Bill-to Customer No."), JobTask.TableCaption);
            if JobTask.SalesLineExist() then
                Error(AssociatedEntriesExistErr, JobTask.FieldCaption("Bill-to Customer No."), JobTask.TableCaption);
        end;
    end;

    local procedure CheckSellToCustomerAssosEntriesExist(var JobTask: Record "Contrato Task"; var xJobTask: Record "Contrato Task")
    begin
        if (JobTask."Sell-to Customer No." = '') or (JobTask."Sell-to Customer No." <> xJobTask."Sell-to Customer No.") then
            if JobTask.SalesJobLedgEntryExist() then
                Error(AssociatedEntriesExistErr, JobTask.FieldCaption("Sell-to Customer No."), JobTask.TableCaption);
    end;

    procedure BilltoContactLookup(): Boolean
    var
        ContactNo: Code[20];
    begin
        ContactNo := ContactLookup("Bill-to Customer No.", "Bill-to Contact No.");
        if ContactNo <> '' then
            Validate("Bill-to Contact No.", ContactNo);
        exit(ContactNo <> '');
    end;

    local procedure ContactLookup(CustomerNo: Code[20]; ContactNo: Code[20]): Code[20]
    begin
        if (CustomerNo <> '') and Cont.Get(ContactNo) then
            Cont.SetRange("Company No.", Cont."Company No.")
        else
            if Cust.Get(CustomerNo) then begin
                if ContBusinessRelation.FindByRelation(ContBusinessRelation."Link to Table"::Customer, CustomerNo) then
                    Cont.SetRange("Company No.", ContBusinessRelation."Contact No.");
            end else
                Cont.SetFilter("Company No.", '<>%1', '''');

        if ContactNo <> '' then
            if Cont.Get(ContactNo) then;
        if Page.RunModal(0, Cont) = Action::LookupOK then
            exit(Cont."No.");
        exit('');
    end;

    procedure LookupSellToCustomerName(var CustomerName: Text): Boolean
    var
        Customer: Record Customer;
        LookupStateManager: Codeunit "Lookup State Manager";
        RecVariant: Variant;
        SearchCustomerName: Text;
    begin
        SearchCustomerName := CustomerName;
        Customer.SetFilter("Date Filter", GetFilter("Posting Date Filter"));
        if "Sell-to Customer No." <> '' then
            Customer.Get("Sell-to Customer No.");

        if Customer.SelectCustomer(Customer) then begin
            if Rec."Sell-to Customer Name" = Customer.Name then
                CustomerName := SearchCustomerName
            else
                CustomerName := Customer.Name;
            RecVariant := Customer;
            LookupStateManager.SaveRecord(RecVariant);
            exit(true);
        end;
    end;

    procedure SelltoCustomerNoOnAfterValidate(var JobTask: Record "Contrato Task"; var xJobTask: Record "Contrato Task")
    begin
        if JobTask.GetFilter("Sell-to Customer No.") = xJobTask."Sell-to Customer No." then
            if JobTask."Sell-to Customer No." <> xJobTask."Sell-to Customer No." then
                JobTask.SetRange("Sell-to Customer No.");
    end;

    local procedure UpdateBillToCust(ContactNo: Code[20])
    begin
        if Cont.Get(ContactNo) then begin
            "Bill-to Contact No." := Cont."No.";
            if Cont.Type = Cont.Type::Person then
                "Bill-to Contact" := Cont.Name
            else
                if Cust.Get("Bill-to Customer No.") then
                    "Bill-to Contact" := Cust.Contact
                else
                    "Bill-to Contact" := '';
        end else begin
            "Bill-to Contact" := '';
            exit;
        end;

        if ContBusinessRelation.FindByContact(ContBusinessRelation."Link to Table"::Customer, Cont."Company No.") then begin
            if "Bill-to Customer No." = '' then
                Validate("Bill-to Customer No.", ContBusinessRelation."No.")
            else
                if "Bill-to Customer No." <> ContBusinessRelation."No." then
                    Error(ContactBusRelErr, Cont."No.", Cont.Name, "Bill-to Customer No.");
        end else
            Error(ContactBusRelMissingErr, Cont."No.", Cont.Name);
    end;

    local procedure ShipToCodeValidate()
    var
        ShipToAddress: Record "Ship-to Address";
    begin
        if not ((xRec."Ship-to Code" <> Rec."Ship-to Code") and (Rec."Ship-to Code" <> '')) then
            exit;

        if not ShipToAddress.Get(Rec."Sell-to Customer No.", Rec."Ship-to Code") then
            exit;

        Rec."Ship-to Name" := ShipToAddress.Name;
        Rec."Ship-to Name 2" := ShipToAddress."Name 2";
        Rec."Ship-to Address" := ShipToAddress.Address;
        Rec."Ship-to Address 2" := ShipToAddress."Address 2";
        Rec."Ship-to City" := ShipToAddress.City;
        Rec."Ship-to County" := ShipToAddress.County;
        Rec."Ship-to Post Code" := ShipToAddress."Post Code";
        Rec."Ship-to Country/Region Code" := ShipToAddress."Country/Region Code";
        Rec."Ship-to Contact" := ShipToAddress.Contact;
    end;

    local procedure UpdateSellToCust(ContactNo: Code[20])
    var
        Customer: Record Customer;
        Contact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
        ContactBusinessRelationFound: Boolean;
    begin
        if not Contact.Get(ContactNo) then begin
            "Sell-to Contact" := '';
            exit;
        end;
        "Sell-to Contact No." := Contact."No.";

        if Contact.Type = Contact.Type::Person then
            ContactBusinessRelationFound := ContactBusinessRelation.FindByContact(ContactBusinessRelation."Link to Table"::Customer, Contact."No.");
        if not ContactBusinessRelationFound then
            ContactBusinessRelationFound := ContactBusinessRelation.FindByContact(ContactBusinessRelation."Link to Table"::Customer, Contact."Company No.");

        if not ContactBusinessRelationFound then
            Error(ContactBusRelMissingErr, Contact."No.", Contact.Name);

        CheckCustomerContactRelation(Contact, "Sell-to Customer No.", ContactBusinessRelation."No.");

        if "Sell-to Customer No." = '' then
            Validate("Sell-to Customer No.", ContactBusinessRelation."No.");

        UpdateSellToCustomerContact(Customer, Contact);

        if ("Sell-to Customer No." = "Bill-to Customer No.") or ("Bill-to Customer No." = '') then
            Validate("Bill-to Contact No.", "Sell-to Contact No.");
    end;

    local procedure CheckCustomerContactRelation(Contact: Record Contact; CustomerNo: Code[20]; ContBusinessRelationNo: Code[20])
    begin
        if (CustomerNo <> '') and (CustomerNo <> ContBusinessRelationNo) then
            Error(ContactBusRelErr, Contact."No.", Contact.Name, CustomerNo);
    end;

    local procedure UpdateSellToCustomerContact(Customer: Record Customer; Contact: Record Contact)
    begin
        if (Contact.Type = Contact.Type::Company) and Customer.Get("Sell-to Customer No.") then
            "Sell-to Contact" := Customer.Contact
        else
            if Contact.Type = Contact.Type::Company then
                "Sell-to Contact" := ''
            else
                "Sell-to Contact" := Contact.Name;
    end;

    local procedure UpdateShipToContact()
    begin
        if not (CurrFieldNo in [FieldNo("Sell-to Contact"), FieldNo("Sell-to Contact No.")]) then
            exit;

        Validate("Ship-to Contact", "Sell-to Contact");
    end;

    procedure SelltoContactLookup(): Boolean
    var
        ContactNo: Code[20];
    begin
        ContactNo := ContactLookup("Sell-to Customer No.", "Sell-to Contact No.");
        if ContactNo <> '' then
            Validate("Sell-to Contact No.", ContactNo);
        exit(ContactNo <> '');
    end;

    procedure ShipToNameEqualsSellToName(): Boolean
    begin
        exit(
            (Rec."Ship-to Name" = Rec."Sell-to Customer Name") and
            (Rec."Ship-to Name 2" = Rec."Sell-to Customer Name 2")
        );
    end;

    procedure BillToAddressEqualsSellToAddress(): Boolean
    begin
        if ("Sell-to Address" = "Bill-to Address") and
           ("Sell-to Address 2" = "Bill-to Address 2") and
           ("Sell-to City" = "Bill-to City") and
           ("Sell-to County" = "Bill-to County") and
           ("Sell-to Post Code" = "Bill-to Post Code") and
           ("Sell-to Country/Region Code" = "Bill-to Country/Region Code") and
           ("Sell-to Contact No." = "Bill-to Contact No.") and
           ("Sell-to Contact" = "Bill-to Contact")
        then
            exit(true);
        exit(false);
    end;

    procedure ShipToAddressEqualsSellToAddress() Result: Boolean
    begin
        Result :=
          ("Sell-to Address" = "Ship-to Address") and
          ("Sell-to Address 2" = "Ship-to Address 2") and
          ("Sell-to City" = "Ship-to City") and
          ("Sell-to County" = "Ship-to County") and
          ("Sell-to Post Code" = "Ship-to Post Code") and
          ("Sell-to Country/Region Code" = "Ship-to Country/Region Code") and
          ("Sell-to Contact" = "Ship-to Contact");

        //OnAfterShipToAddressEqualsSellToAddress(Rec, Result);
    end;

    procedure SyncShipToWithSellTo()
    begin
        Rec."Ship-to Name" := Rec."Sell-to Customer Name";
        Rec."Ship-to Name 2" := Rec."Sell-to Customer Name 2";
        Rec."Ship-to Address" := Rec."Sell-to Address";
        Rec."Ship-to Address 2" := Rec."Sell-to Address 2";
        Rec."Ship-to City" := Rec."Sell-to City";
        Rec."Ship-to County" := Rec."Sell-to County";
        Rec."Ship-to Post Code" := Rec."Sell-to Post Code";
        Rec."Ship-to Country/Region Code" := Rec."Sell-to Country/Region Code";
        Rec."Ship-to Contact" := Rec."Sell-to Contact";
        Rec."Ship-to Code" := '';

        // OnAfterSyncShipToWithSellTo(Rec);
    end;

    procedure JobLedgEntryExist() Result: Boolean
    var
        JobLedgEntry: Record "Contrato Ledger Entry";
    begin
        JobLedgEntry.SetCurrentKey("Contrato No.");
        JobLedgEntry.SetRange("Contrato No.", "Contrato No.");
        JobLedgEntry.SetRange("Contrato Task No.", "Contrato Task No.");
        Result := not JobLedgEntry.IsEmpty();
    end;

    procedure JobPlanLineExist() Result: Boolean
    var
        JobPlanningLine: Record "Contrato Planning Line";
    begin
        JobPlanningLine.Init();
        JobPlanningLine.SetRange("Contrato No.", "Contrato No.");
        JobPlanningLine.SetRange("Contrato Task No.", "Contrato Task No.");
        Result := not JobPlanningLine.IsEmpty();
    end;

    procedure SendProfile(var DocumentSendingProfile: Record "Document Sending Profile")
    var
        ReportSelections: Record "Report Selections";
        ReportDistributionMgt: Codeunit "Report Distribution Management";
    begin
        DocumentSendingProfile.Send(
          ReportSelections.Usage::"Job Task Quote".AsInteger(), Rec, "Contrato Task No.", "Bill-to Customer No.",
          ReportDistributionMgt.GetFullDocumentTypeText(Rec), FieldNo("Bill-to Customer No."), FieldNo("Contrato Task No."));
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    procedure GetHideValidationDialog(): Boolean
    begin
        exit(HideValidationDialog);
    end;

    procedure SuspendDeletionCheck(Suspend: Boolean)
    begin
        CalledFromHeader := Suspend;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterApplyPurchaseLineFilters(var JobTask: Record "Contrato Task"; var PurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateShortcutDimCode(var JobTask: Record "Contrato Task"; var xJobTask: Record "Contrato Task"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOnInsert(var JobTask: Record "Contrato Task"; var xJobTask: Record "Contrato Task")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnInsert(var JobTask: Record "Contrato Task"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnModify(var JobTask: Record "Contrato Task"; xJobTask: Record "Contrato Task"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateJobTaskNo(var JobTask: Record "Contrato Task"; var xJobTask: Record "Contrato Task"; FieldNumber: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateJobPostingGroup(var JobTask: Record "Contrato Task"; xJobTask: Record "Contrato Task"; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateShortcutDimCode(var JobTask: Record "Contrato Task"; var xJobTask: Record "Contrato Task"; FieldNumber: Integer; var ShortcutDimCode: Code[20]; JobTask2: Record "Contrato Task"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitWIPFieldsOnBeforeModify(var JobTask: Record "Contrato Task")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnJobLedgEntriesExistOnAfterSetFilter(var JobTask: Record "Contrato Task"; var JobLedgerEntry: Record "Contrato Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCaption(JobTask: Record "Contrato Task"; var IsHandled: Boolean; var Result: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterShipToAddressEqualsSellToAddress(var JobTask: Record "Contrato Task"; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSyncShipToWithSellTo(var JobTask: Record "Contrato Task")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateCostPricesOnRelatedJobPlanningLinesOnBeforeConfirmUpdate(var JobTask: Record "Contrato Task"; var ConfirmResult: Boolean; var IsHandled: Boolean)
    begin
    end;
}

