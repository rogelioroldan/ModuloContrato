table 50227 "Contrato WIP Buffer"
{
    Caption = 'contrato WIP Buffer';
    ReplicateData = false;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Posting Group"; Code[20])
        {
            Caption = 'Posting Group';
            DataClassification = SystemMetadata;
        }
        field(2; Type; Enum "Contrato WIP Buffer Type")
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
        }
        field(3; "WIP Entry Amount"; Decimal)
        {
            Caption = 'WIP Entry Amount';
            DataClassification = SystemMetadata;
        }
        field(4; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            DataClassification = SystemMetadata;
            TableRelation = "G/L Account";
        }
        field(5; "Bal. G/L Account No."; Code[20])
        {
            Caption = 'Bal. G/L Account No.';
            DataClassification = SystemMetadata;
            TableRelation = "G/L Account";
        }
        field(6; "WIP Method"; Code[20])
        {
            Caption = 'WIP Method';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(7; "Contrato No."; Code[20])
        {
            Caption = 'contrato No.';
            DataClassification = SystemMetadata;
            Editable = false;
            NotBlank = true;
            TableRelation = Contrato;
        }
        field(8; "Contrato Complete"; Boolean)
        {
            Caption = 'contrato Complete';
            DataClassification = SystemMetadata;
        }
        field(9; "Contrato WIP Total Entry No."; Integer)
        {
            Caption = 'contrato WIP Total Entry No.';
            DataClassification = SystemMetadata;
            TableRelation = "Contrato WIP Total";
        }
        field(22; Reverse; Boolean)
        {
            Caption = 'Reverse';
            DataClassification = SystemMetadata;
            InitValue = true;
        }
        field(23; "WIP Posting Method Used"; Option)
        {
            Caption = 'WIP Posting Method Used';
            DataClassification = SystemMetadata;
            OptionCaption = 'Per contrato,Per contrato Ledger Entry';
            OptionMembers = "Per Contrato","Per Contrato Ledger Entry";
        }
        field(71; "Dim Combination ID"; Integer)
        {
            Caption = 'Dim Combination ID';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Contrato No.", "Contrato WIP Total Entry No.", Type, "Posting Group", "Dim Combination ID", Reverse, "G/L Account No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

