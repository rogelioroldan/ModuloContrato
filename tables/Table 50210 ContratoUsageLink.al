table 50210 "Contrato Usage Link"
{
    Caption = 'contrato Usage Link';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Contrato No."; Code[20])
        {
            Caption = 'contrato No.';
            TableRelation = Contrato;
        }
        field(2; "Contrato Task No."; Code[20])
        {
            Caption = 'contrato Task No.';
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

    procedure Create(ContratoPlanningLine: Record "Contrato Planning Line"; ContratoLedgerEntry: Record "Contrato Ledger Entry")
    begin
        if Get(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.", ContratoPlanningLine."Line No.", ContratoLedgerEntry."Entry No.") then
            exit;

        Validate("Contrato No.", ContratoPlanningLine."Contrato No.");
        Validate("Contrato Task No.", ContratoPlanningLine."Contrato Task No.");
        Validate("Line No.", ContratoPlanningLine."Line No.");
        Validate("Entry No.", ContratoLedgerEntry."Entry No.");
        Insert(true);
    end;
}

