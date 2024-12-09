table 50225 "Contrato Task Archive"
{
    Caption = 'Project Task';
    DrillDownPageID = "Contrato Task Archive Lines";
    LookupPageID = "Contrato Task Archive Lines";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Contrato No."; Code[20])
        {
            Caption = 'Project No.';
            Editable = false;
            NotBlank = true;
            TableRelation = "Contrato Archive";
        }
        field(2; "Contrato Task No."; Code[20])
        {
            Caption = 'Project Task No.';
            NotBlank = true;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(4; "Contrato Task Type"; Enum "Contrato Task Type")
        {
            Caption = 'Project Task Type';
        }
        field(6; "WIP-Total"; Option)
        {
            Caption = 'WIP-Total';
            OptionCaption = ' ,Total,Excluded';
            OptionMembers = " ",Total,Excluded;
        }
        field(7; "Contrato Posting Group"; Code[20])
        {
            Caption = 'Project Posting Group';
            TableRelation = "Contrato Posting Group";
        }
        field(9; "WIP Method"; Code[20])
        {
            Caption = 'WIP Method';
            TableRelation = "Contrato WIP Method".Code where(Valid = const(true));
        }
        field(10; "Schedule (Total Cost)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Contrato Planning Line Archive"."Total Cost (LCY)" where("Contrato No." = field("Contrato No."),
                                                                            "Contrato Task No." = field("Contrato Task No."),
                                                                            "Contrato Task No." = field(filter(Totaling)),
                                                                            "Schedule Line" = const(true),
                                                                            "Planning Date" = field("Planning Date Filter"),
                                                                            "Version No." = field("Version No.")));
            Caption = 'Budget (Total Cost)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Schedule (Total Price)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Contrato Planning Line Archive"."Line Amount (LCY)" where("Contrato No." = field("Contrato No."),
                                                                             "Contrato Task No." = field("Contrato Task No."),
                                                                             "Contrato Task No." = field(filter(Totaling)),
                                                                             "Schedule Line" = const(true),
                                                                             "Planning Date" = field("Planning Date Filter"),
                                                                             "Version No." = field("Version No.")));
            Caption = 'Budget (Total Price)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(12; "Usage (Total Cost)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Actual (Total Cost)';
        }
        field(13; "Usage (Total Price)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Actual (Total Price)';
        }
        field(14; "Contract (Total Cost)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Contrato Planning Line Archive"."Total Cost (LCY)" where("Contrato No." = field("Contrato No."),
                                                                            "Contrato Task No." = field("Contrato Task No."),
                                                                            "Contrato Task No." = field(filter(Totaling)),
                                                                            "Contract Line" = const(true),
                                                                            "Planning Date" = field("Planning Date Filter"),
                                                                            "Version No." = field("Version No.")));
            Caption = 'Billable (Total Cost)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "Contract (Total Price)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Contrato Planning Line Archive"."Line Amount (LCY)" where("Contrato No." = field("Contrato No."),
                                                                             "Contrato Task No." = field("Contrato Task No."),
                                                                             "Contrato Task No." = field(filter(Totaling)),
                                                                             "Contract Line" = const(true),
                                                                             "Planning Date" = field("Planning Date Filter"),
                                                                             "Version No." = field("Version No.")));
            Caption = 'Billable (Total Price)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(16; "Contract (Invoiced Price)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Invoiced (Total Price)';
        }
        field(17; "Contract (Invoiced Cost)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Invoiced (Total Cost)';
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
        }
        field(31; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = Bin.Code where("Location Code" = field("Location Code"));
            DataClassification = CustomerContent;
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
        }
        field(61; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));
        }
        field(62; "Outstanding Orders"; Decimal)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            Caption = 'Outstanding Orders';
        }
        field(63; "Amt. Rcd. Not Invoiced"; Decimal)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            Caption = 'Amt. Rcd. Not Invoiced';
        }
        field(64; "Remaining (Total Cost)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Contrato Planning Line Archive"."Remaining Total Cost (LCY)" where("Contrato No." = field("Contrato No."),
                                                                                      "Contrato Task No." = field("Contrato Task No."),
                                                                                      "Contrato Task No." = field(filter(Totaling)),
                                                                                      "Schedule Line" = const(true),
                                                                                      "Planning Date" = field("Planning Date Filter"),
                                                                                      "Version No." = field("Version No.")));
            Caption = 'Remaining (Total Cost)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(65; "Remaining (Total Price)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = sum("Contrato Planning Line Archive"."Remaining Line Amount (LCY)" where("Contrato No." = field("Contrato No."),
                                                                                       "Contrato Task No." = field("Contrato Task No."),
                                                                                       "Contrato Task No." = field(filter(Totaling)),
                                                                                       "Schedule Line" = const(true),
                                                                                       "Planning Date" = field("Planning Date Filter"),
                                                                                       "Version No." = field("Version No.")));
            Caption = 'Remaining (Total Price)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(66; "Start Date"; Date)
        {
            CalcFormula = min("Contrato Planning Line Archive"."Planning Date" where("Contrato No." = field("Contrato No."),
                                                                         "Contrato Task No." = field("Contrato Task No."),
                                                                         "Version No." = field("Version No.")));
            Caption = 'Start Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(67; "End Date"; Date)
        {
            CalcFormula = max("Contrato Planning Line Archive"."Planning Date" where("Contrato No." = field("Contrato No."),
                                                                         "Contrato Task No." = field("Contrato Task No."),
                                                                         "Version No." = field("Version No.")));
            Caption = 'End Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(70; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            TableRelation = Customer;
            DataClassification = CustomerContent;
        }
        field(71; "Bill-to Name"; Text[100])
        {
            Caption = 'Bill-to Name';
            TableRelation = Customer.Name;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
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
        }
        field(77; "Bill-to Country/Region Code"; Code[10])
        {
            Caption = 'Bill-to Country/Region Code';
            Editable = true;
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
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
        }
        field(91; "Sell-to Customer Name"; Text[100])
        {
            Caption = 'Sell-to Customer Name';
            TableRelation = Customer.Name;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
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
        }
        field(110; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            TableRelation = "Ship-to Address".Code where("Customer No." = field("Sell-to Customer No."));
            DataClassification = CustomerContent;
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
        }
        field(134; "Price Calculation Method"; Enum "Price Calculation Method")
        {
            Caption = 'Price Calculation Method';
            DataClassification = CustomerContent;
        }
        field(140; "Invoice Currency Code"; Code[10])
        {
            Caption = 'Invoice Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(5047; "Version No."; Integer)
        {
            Caption = 'Version No.';
        }
    }

    keys
    {
        key(Key1; "Contrato No.", "Contrato Task No.", "Version No.")
        {
            Clustered = true;
        }
        key(Key2; "Contrato Task No.")
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
        ContratoPlanningLineArchive: Record "Contrato Planning Line Archive";
    begin
        ContratoPlanningLineArchive.SetRange("Contrato No.", "Contrato No.");
        ContratoPlanningLineArchive.SetRange("Contrato Task No.", "Contrato Task No.");
        ContratoPlanningLineArchive.SetRange("Version No.", "Version No.");
        ContratoPlanningLineArchive.DeleteAll(true);
    end;
}

