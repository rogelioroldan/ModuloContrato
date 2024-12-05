table 50210 "Contrato Usage Link"
{
    Caption = 'Project Usage Link';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Contrato No."; Code[20])
        {
            Caption = 'Project No.';
            TableRelation = Contrato;
        }
        field(2; "Contrato Task No."; Code[20])
        {
            Caption = 'Project Task No.';
            TableRelation = "Contrato Task"."Contrato Task No." where("Contrato No." = field("Contrato No."));
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            TableRelation = "Contrato Planning Line"."Line No." where("Contrato No." = field("Contrato No."),
                                                                  "Contrato Task No." = field("Contrato Task No."));
        }
        field(4; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(5; "External Id"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'External Id';
        }
    }

    keys
    {
        key(Key1; "Contrato No.", "Contrato Task No.", "Line No.", "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "External Id")
        {
        }
    }

    fieldgroups
    {
    }

    procedure Create(JobPlanningLine: Record "Contrato Planning Line"; JobLedgerEntry: Record "Contrato Ledger Entry")
    begin
        if Get(JobPlanningLine."Contrato No.", JobPlanningLine."Contrato Task No.", JobPlanningLine."Line No.", JobLedgerEntry."Entry No.") then
            exit;

        Validate("Contrato No.", JobPlanningLine."Contrato No.");
        Validate("Contrato Task No.", JobPlanningLine."Contrato Task No.");
        Validate("Line No.", JobPlanningLine."Line No.");
        Validate("Entry No.", JobLedgerEntry."Entry No.");
        Insert(true);
    end;
}

