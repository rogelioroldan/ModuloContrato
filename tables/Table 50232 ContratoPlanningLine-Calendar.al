table 50232 "ContratoPlanningLine-Calendar"
{
    Caption = 'Contrato Planning Line - Calendar';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Contrato No."; Code[20])
        {
            Caption = 'Contrato No.';
            TableRelation = "Contrato Planning Line"."Contrato No.";
        }
        field(2; "Contrato Task No."; Code[20])
        {
            Caption = 'Contrato Task No.';
            TableRelation = "Contrato Planning Line"."Contrato Task No.";
        }
        field(3; "Planning Line No."; Integer)
        {
            Caption = 'Planning Line No.';
            TableRelation = "Contrato Planning Line"."Line No.";
        }
        field(4; "Resource No."; Code[20])
        {
            Caption = 'Resource No.';
            TableRelation = Resource."No.";
        }
        field(6; "Planning Date"; Date)
        {
            Caption = 'Planning Date';
        }
        field(7; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(9; UID; Guid)
        {
            Caption = 'UID';
        }
        field(10; Sequence; Integer)
        {
            Caption = 'Sequence';
            InitValue = 1;
        }
    }

    keys
    {
        key(Key1; "Contrato No.", "Contrato Task No.", "Planning Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        UID := CreateGuid();
    end;

    trigger OnModify()
    begin
        Sequence += 1;
    end;

    procedure HasBeenSent(ContratoPlanningLine: Record "Contrato Planning Line"): Boolean
    begin
        exit(Get(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.", ContratoPlanningLine."Line No."));
    end;

    procedure InsertOrUpdate(ContratoPlanningLine: Record "Contrato Planning Line")
    begin
        if not HasBeenSent(ContratoPlanningLine) then begin
            Init();
            "Contrato No." := ContratoPlanningLine."Contrato No.";
            "Contrato Task No." := ContratoPlanningLine."Contrato Task No.";
            "Planning Line No." := ContratoPlanningLine."Line No.";
            "Resource No." := ContratoPlanningLine."No.";
            Quantity := ContratoPlanningLine.Quantity;
            "Planning Date" := ContratoPlanningLine."Planning Date";
            Description := ContratoPlanningLine.Description;
            Insert(true);
        end else begin
            Quantity := ContratoPlanningLine.Quantity;
            "Planning Date" := ContratoPlanningLine."Planning Date";
            Description := ContratoPlanningLine.Description;
            Modify(true);
        end;
    end;

    procedure ShouldSendCancellation(ContratoPlanningLine: Record "Contrato Planning Line"): Boolean
    var
        LocalContratoPlanningLine: Record "Contrato Planning Line";
    begin
        if not LocalContratoPlanningLine.Get(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.", ContratoPlanningLine."Line No.") then
            exit(true);
        if HasBeenSent(ContratoPlanningLine) then
            exit(ContratoPlanningLine."No." <> "Resource No.");
    end;

    procedure ShouldSendRequest(ContratoPlanningLine: Record "Contrato Planning Line") ShouldSend: Boolean
    var
        LocalContratoPlanningLine: Record "Contrato Planning Line";
    begin
        ShouldSend := true;
        if not LocalContratoPlanningLine.Get(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.", ContratoPlanningLine."Line No.") then
            exit(false);
        if HasBeenSent(ContratoPlanningLine) then
            ShouldSend :=
              ("Resource No." <> ContratoPlanningLine."No.") or
              ("Planning Date" <> ContratoPlanningLine."Planning Date") or
              (Quantity <> ContratoPlanningLine.Quantity) or
              (Description <> ContratoPlanningLine.Description);
    end;
}

