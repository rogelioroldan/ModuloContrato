table 50223 "My Contrato"
{
    Caption = 'My Contrato';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(2; "Contrato No."; Code[20])
        {
            Caption = 'Contrato No.';
            NotBlank = true;
            TableRelation = Contrato;
        }
        field(3; "Exclude from Business Chart"; Boolean)
        {
            Caption = 'Exclude from Business Chart';
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(5; Status; Enum "Contrato Status")
        {
            Caption = 'Status';
            InitValue = Open;
        }
        field(6; "Bill-to Name"; Text[100])
        {
            Caption = 'Bill-to Name';
        }
        field(7; "Percent Completed"; Decimal)
        {
            Caption = 'Percent Completed';
        }
        field(8; "Percent Invoiced"; Decimal)
        {
            Caption = 'Percent Invoiced';
        }
    }

    keys
    {
        key(Key1; "User ID", "Contrato No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

