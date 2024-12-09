table 50215 "Contrato WIP Entry"
{
    Caption = 'Project WIP Entry';
    DrillDownPageID = "Contrato WIP Entries";
    LookupPageID = "Contrato WIP Entries";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Contrato No."; Code[20])
        {
            Caption = 'Project No.';
            TableRelation = Contrato;
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(4; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            TableRelation = "G/L Account";
        }
        field(5; "WIP Posting Date"; Date)
        {
            Caption = 'WIP Posting Date';
        }
        field(6; "WIP Entry Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'WIP Entry Amount';
        }
        field(7; "Contrato Posting Group"; Code[20])
        {
            Caption = 'Project Posting Group';
            TableRelation = "Contrato Posting Group";
        }
        field(8; Type; Enum "Contrato WIP Buffer Type")
        {
            Caption = 'Type';
        }
        field(9; "G/L Bal. Account No."; Code[20])
        {
            Caption = 'G/L Bal. Account No.';
            TableRelation = "G/L Account";
        }
        field(10; "WIP Method Used"; Code[20])
        {
            Caption = 'WIP Method Used';
            Editable = false;
            TableRelation = "Contrato WIP Method";
        }
        field(11; "Contrato Complete"; Boolean)
        {
            Caption = 'Project Complete';
        }
        field(12; "Contrato WIP Total Entry No."; Integer)
        {
            Caption = 'Project WIP Total Entry No.';
            TableRelation = "Contrato WIP Total";
        }
        field(13; Reverse; Boolean)
        {
            Caption = 'Reverse';
            InitValue = true;
        }
        field(14; "WIP Posting Method Used"; Option)
        {
            Caption = 'WIP Posting Method Used';
            OptionCaption = 'Per Project,Per Project Ledger Entry';
            OptionMembers = "Per Contrato","Per Contrato Ledger Entry";
        }
        field(60; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(61; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                Rec.ShowDimensions();
            end;
        }
        field(481; "Shortcut Dimension 3 Code"; Code[20])
        {
            CaptionClass = '1,2,3';
            Caption = 'Shortcut Dimension 3 Code';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"),
                                                                                    "Global Dimension No." = const(3)));
        }
        field(482; "Shortcut Dimension 4 Code"; Code[20])
        {
            CaptionClass = '1,2,4';
            Caption = 'Shortcut Dimension 4 Code';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"),
                                                                                    "Global Dimension No." = const(4)));
        }
        field(483; "Shortcut Dimension 5 Code"; Code[20])
        {
            CaptionClass = '1,2,5';
            Caption = 'Shortcut Dimension 5 Code';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"),
                                                                                    "Global Dimension No." = const(5)));
        }
        field(484; "Shortcut Dimension 6 Code"; Code[20])
        {
            CaptionClass = '1,2,6';
            Caption = 'Shortcut Dimension 6 Code';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"),
                                                                                    "Global Dimension No." = const(6)));
        }
        field(485; "Shortcut Dimension 7 Code"; Code[20])
        {
            CaptionClass = '1,2,7';
            Caption = 'Shortcut Dimension 7 Code';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"),
                                                                                    "Global Dimension No." = const(7)));
        }
        field(486; "Shortcut Dimension 8 Code"; Code[20])
        {
            CaptionClass = '1,2,8';
            Caption = 'Shortcut Dimension 8 Code';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"),
                                                                                    "Global Dimension No." = const(8)));
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Contrato No.", "Contrato Posting Group", "WIP Posting Date", Type, "Contrato Complete")
        {
            SumIndexFields = "WIP Entry Amount";
        }
        key(Key3; "G/L Account No.")
        {
        }
        key(Key4; "Contrato No.", "Contrato Complete", Type)
        {
            SumIndexFields = "WIP Entry Amount";
        }
    }

    fieldgroups
    {
    }

    var
        DimMgt: Codeunit DimensionManagement;

    procedure DeleteEntriesForContrato(Contrato: Record Contrato)
    begin
        SetCurrentKey("Contrato No.");
        SetRange("Contrato No.", Contrato."No.");
        if not IsEmpty() then
            DeleteAll(true);
    end;

    procedure GetLastEntryNo(): Integer;
    var
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        exit(FindRecordManagement.GetLastEntryIntFieldValue(Rec, FieldNo("Entry No.")))
    end;

    procedure ShowDimensions()
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2', TableCaption(), "Entry No."));
    end;
}

