table 50212 "Contrato Posting Group"
{
    Caption = 'contrato Posting Group';
    DrillDownPageID = "Contrato Posting Groups";
    LookupPageID = "Contrato Posting Groups";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; "WIP Costs Account"; Code[20])
        {
            Caption = 'WIP Costs Account';
            TableRelation = "G/L Account";
        }
        field(3; "WIP Accrued Costs Account"; Code[20])
        {
            Caption = 'WIP Accrued Costs Account';
            TableRelation = "G/L Account";
        }
        field(4; "Contrato Costs Applied Account"; Code[20])
        {
            Caption = 'contrato Costs Applied Account';
            TableRelation = "G/L Account";
        }
        field(5; "ContratCostsAdjustmentAccount"; Code[20])
        {
            Caption = 'contrato Costs Adjustment Account';
            TableRelation = "G/L Account";
        }
        field(6; "G/L Expense Acc. (Contract)"; Code[20])
        {
            Caption = 'G/L Expense Acc. (Contract)';
            TableRelation = "G/L Account";
        }
        field(7; "ContratoSalesAdjustmentAccount"; Code[20])
        {
            Caption = 'contrato Sales Adjustment Account';
            TableRelation = "G/L Account";
        }
        field(8; "WIP Accrued Sales Account"; Code[20])
        {
            Caption = 'WIP Accrued Sales Account';
            TableRelation = "G/L Account";
        }
        field(9; "WIP Invoiced Sales Account"; Code[20])
        {
            Caption = 'WIP Invoiced Sales Account';
            TableRelation = "G/L Account";
        }
        field(10; "Contrato Sales Applied Account"; Code[20])
        {
            Caption = 'contrato Sales Applied Account';
            TableRelation = "G/L Account";
        }
        field(11; "Recognized Costs Account"; Code[20])
        {
            Caption = 'Recognized Costs Account';
            TableRelation = "G/L Account";
        }
        field(12; "Recognized Sales Account"; Code[20])
        {
            Caption = 'Recognized Sales Account';
            TableRelation = "G/L Account";
        }
        field(13; "Item Costs Applied Account"; Code[20])
        {
            Caption = 'Item Costs Applied Account';
            TableRelation = "G/L Account";
        }
        field(14; "Resource Costs Applied Account"; Code[20])
        {
            Caption = 'Resource Costs Applied Account';
            TableRelation = "G/L Account";
        }
        field(15; "G/L Costs Applied Account"; Code[20])
        {
            Caption = 'G/L Costs Applied Account';
            TableRelation = "G/L Account";
        }
        field(20; Description; Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "Code")
        {
        }
    }

    trigger OnDelete()
    begin
        CheckGroupUsage();
    end;

    var
        PostingSetupMgt: Codeunit PostingSetupManagement;
        YouCannotDeleteErr: Label 'You cannot delete %1.', Comment = '%1 = Code';

    local procedure CheckGroupUsage()
    var
        Contrato: Record Contrato;
        ContratoLedgerEntry: Record "Contrato Ledger Entry";
    begin
        Contrato.SetRange("Contrato Posting Group", Code);
        if not Contrato.IsEmpty() then
            Error(YouCannotDeleteErr, Code);

        ContratoLedgerEntry.SetRange("Contrato Posting Group", Code);
        if not ContratoLedgerEntry.IsEmpty() then
            Error(YouCannotDeleteErr, Code);
    end;

    procedure GetWIPCostsAccount(): Code[20]
    begin
        if "WIP Costs Account" = '' then
            //PostingSetupMgt.LogContratoPostingGroupFieldError(Rec, FieldNo("WIP Costs Account"));

        exit("WIP Costs Account");
    end;

    procedure GetWIPAccruedCostsAccount(): Code[20]
    begin
        if "WIP Accrued Costs Account" = '' then
            //PostingSetupMgt.LogContratoPostingGroupFieldError(Rec, FieldNo("WIP Accrued Costs Account"));

        exit("WIP Accrued Costs Account");
    end;

    procedure GetWIPAccruedSalesAccount(): Code[20]
    begin
        if "WIP Accrued Sales Account" = '' then
            //PostingSetupMgt.LogContratoPostingGroupFieldError(Rec, FieldNo("WIP Accrued Sales Account"));

        exit("WIP Accrued Sales Account");
    end;

    procedure GetWIPInvoicedSalesAccount(): Code[20]
    begin
        if "WIP Invoiced Sales Account" = '' then
            //PostingSetupMgt.LogContratoPostingGroupFieldError(Rec, FieldNo("WIP Invoiced Sales Account"));

        exit("WIP Invoiced Sales Account");
    end;

    procedure GetContratoCostsAppliedAccount(): Code[20]
    begin
        if "Contrato Costs Applied Account" = '' then
            //PostingSetupMgt.LogContratoPostingGroupFieldError(Rec, FieldNo("Contrato Costs Applied Account"));

        exit("Contrato Costs Applied Account");
    end;

    procedure GetContratoCostsAdjustmentAccount(): Code[20]
    begin
        if "ContratCostsAdjustmentAccount" = '' then
            //PostingSetupMgt.LogContratoPostingGroupFieldError(Rec, FieldNo("ContratCostsAdjustmentAccount"));

        exit("ContratCostsAdjustmentAccount");
    end;

    procedure GetGLExpenseAccountContract(): Code[20]
    begin
        if "G/L Expense Acc. (Contract)" = '' then
            //PostingSetupMgt.LogContratoPostingGroupFieldError(Rec, FieldNo("G/L Expense Acc. (Contract)"));

        exit("G/L Expense Acc. (Contract)");
    end;

    procedure GetContratoSalesAdjustmentAccount(): Code[20]
    begin
        if "ContratoSalesAdjustmentAccount" = '' then
            //PostingSetupMgt.LogContratoPostingGroupFieldError(Rec, FieldNo("ContratoSalesAdjustmentAccount"));

        exit("ContratoSalesAdjustmentAccount");
    end;

    procedure GetContratoSalesAppliedAccount(): Code[20]
    begin
        if "Contrato Sales Applied Account" = '' then
            //PostingSetupMgt.LogContratoPostingGroupFieldError(Rec, FieldNo("Contrato Sales Applied Account"));

        exit("Contrato Sales Applied Account");
    end;

    procedure GetRecognizedCostsAccount(): Code[20]
    begin
        if "Recognized Costs Account" = '' then
            //PostingSetupMgt.LogContratoPostingGroupFieldError(Rec, FieldNo("Recognized Costs Account"));

        exit("Recognized Costs Account");
    end;

    procedure GetRecognizedSalesAccount(): Code[20]
    begin
        if "Recognized Sales Account" = '' then
            //PostingSetupMgt.LogContratoPostingGroupFieldError(Rec, FieldNo("Recognized Sales Account"));

        exit("Recognized Sales Account");
    end;

    procedure GetItemCostsAppliedAccount(): Code[20]
    begin
        if "Item Costs Applied Account" = '' then
            //PostingSetupMgt.LogContratoPostingGroupFieldError(Rec, FieldNo("Item Costs Applied Account"));

        exit("Item Costs Applied Account");
    end;

    procedure GetResourceCostsAppliedAccount(): Code[20]
    begin
        if "Resource Costs Applied Account" = '' then
            //PostingSetupMgt.LogContratoPostingGroupFieldError(Rec, FieldNo("Resource Costs Applied Account"));

        exit("Resource Costs Applied Account");
    end;

    procedure GetGLCostsAppliedAccount(): Code[20]
    begin
        if "G/L Costs Applied Account" = '' then
            //PostingSetupMgt.LogContratoPostingGroupFieldError(Rec, FieldNo("G/L Costs Applied Account"));

        exit("G/L Costs Applied Account");
    end;
}

