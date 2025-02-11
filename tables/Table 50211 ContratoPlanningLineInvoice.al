table 50211 "Contrato Planning Line Invoice"
{
    Caption = 'Contrato Planning Line Invoice';
    DrillDownPageID = "Contrato Invoices";
    LookupPageID = "Contrato Invoices";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Contrato No."; Code[20])
        {
            Caption = 'contrato No.';
            Editable = false;
            TableRelation = Contrato;
        }
        field(2; "Contrato Task No."; Code[20])
        {
            Caption = 'contrato Task No.';
            Editable = false;
            TableRelation = "Contrato Task"."Contrato Task No." where("Contrato No." = field("Contrato No."));
        }
        field(3; "Contrato Planning Line No."; Integer)
        {
            Caption = 'contrato Planning Line No.';
            Editable = false;
            TableRelation = "Contrato Planning Line"."Line No." where("Contrato No." = field("Contrato No."),
                                                                  "Contrato Task No." = field("Contrato Task No."));
        }
        field(4; "Document Type"; Enum ContratoPlanningLineInvoiceDT)
        {
            Caption = 'Document Type';
            Editable = false;
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
        }
        field(6; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(7; "Quantity Transferred"; Decimal)
        {
            Caption = 'Quantity Transferred';
            Editable = false;
        }
        field(8; "Transferred Date"; Date)
        {
            Caption = 'Transferred Date';
            Editable = false;
        }
        field(9; "Invoiced Date"; Date)
        {
            Caption = 'Invoiced Date';
            Editable = false;
        }
        field(10; "Invoiced Amount (LCY)"; Decimal)
        {
            Caption = 'Invoiced Amount (LCY)';
            Editable = false;
        }
        field(11; "Invoiced Cost Amount (LCY)"; Decimal)
        {
            Caption = 'Invoiced Cost Amount (LCY)';
            Editable = false;
        }
        field(12; "Contrato Ledger Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'contrato Ledger Entry No.';
            Editable = false;
            TableRelation = "Contrato Ledger Entry";
        }
    }

    keys
    {
        key(Key1; "Contrato No.", "Contrato Task No.", "Contrato Planning Line No.", "Document Type", "Document No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Document Type", "Document No.", "Contrato Ledger Entry No.")
        {
        }
        key(Key3; "Contrato No.", "Contrato Planning Line No.", "Contrato Task No.", "Document Type")
        {
            MaintainSqlIndex = false;
            SumIndexFields = "Quantity Transferred", "Invoiced Amount (LCY)", "Invoiced Cost Amount (LCY)";
        }
    }

    fieldgroups
    {
    }

    procedure InitFromContratoPlanningLine(ContratoPlanningLine: Record "Contrato Planning Line")
    begin
        "Contrato No." := ContratoPlanningLine."Contrato No.";
        "Contrato Task No." := ContratoPlanningLine."Contrato Task No.";
        "Contrato Planning Line No." := ContratoPlanningLine."Line No.";
        "Quantity Transferred" := ContratoPlanningLine."Qty. to Transfer to Invoice";

        OnAfterInitFromContratoPlanningLine(Rec, ContratoPlanningLine);
    end;

    procedure InitFromSales(SalesHeader: Record "Sales Header"; PostingDate: Date; LineNo: Integer)
    begin
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice then
            "Document Type" := "Document Type"::Invoice;
        if SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo" then
            "Document Type" := "Document Type"::"Credit Memo";
        "Document No." := SalesHeader."No.";
        "Line No." := LineNo;
        "Transferred Date" := PostingDate
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitFromContratoPlanningLine(var ContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice"; ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;
}

