codeunit 50216 "Copy Contrato"
{

    trigger OnRun()
    begin
    end;

    var
        CopyPrices: Boolean;
        CopyQuantity: Boolean;
        CopyDimensions: Boolean;
        ContratoPlanningLineSource: Option "Contrato Planning Lines","Contrato Ledger Entries";
        ContratoPlanningLineType: Option " ",Budget,Billable;
        ContratoLedgerEntryType: Option " ",Usage,Sale;
        ContratoTaskRangeFrom: Code[20];
        ContratoTaskRangeTo: Code[20];
        ContratoTaskDateRangeFrom: Date;
        ContratoTaskDateRangeTo: Date;

    procedure CopyContrato(
        SourceContrato: Record Contrato;
        TargetContratoNo: Code[20];
        TargetContratoDescription: Text[100];
        TargetContratoSellToCustomer: Code[20];
        TargetContratoBillToCustomer: Code[20]
    )
    var
        TargetContrato: Record Contrato;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyContrato(SourceContrato, TargetContratoNo, TargetContratoDescription, TargetContratoSellToCustomer, TargetContratoBillToCustomer, CopyDimensions, CopyPrices, IsHandled);
        if IsHandled then
            exit;

        TargetContrato.SetHideValidationDialog(true);
        TargetContrato."No." := TargetContratoNo;
        TargetContrato.TransferFields(SourceContrato, false);
        TargetContrato.Insert(true);
        if TargetContratoDescription <> '' then
            TargetContrato.Validate(Description, TargetContratoDescription);
        if TargetContratoSellToCustomer <> '' then
            TargetContrato.Validate("Sell-to Customer No.", TargetContratoSellToCustomer);
        if TargetContratoBillToCustomer <> '' then
            TargetContrato.Validate("Bill-to Customer No.", TargetContratoBillToCustomer);
        TargetContrato.Validate(Status, TargetContrato.Status::Planning);
        if CopyDimensions then
            CopyContratoDimensions(SourceContrato, TargetContrato);
        CopyContratoTasks(SourceContrato, TargetContrato);

        if CopyPrices then
            OnBeforeCopyContratoPrices(SourceContrato, TargetContrato);

        OnAfterCopyContrato(TargetContrato, SourceContrato);
        TargetContrato.Modify();
    end;

    procedure CopyContratoTasks(SourceContrato: Record Contrato; TargetContrato: Record Contrato)
    var
        SourceContratoTask: Record "Contrato Task";
        TargetContratoTask: Record "Contrato Task";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyContratoTasks(SourceContrato, TargetContrato, IsHandled, CopyDimensions, CopyQuantity, CopyPrices, ContratoTaskRangeFrom, ContratoTaskRangeTo, ContratoPlanningLineSource, ContratoLedgerEntryType);
        if IsHandled then
            exit;

        SourceContratoTask.SetRange("Contrato No.", SourceContrato."No.");
        case true of
            (ContratoTaskRangeFrom <> '') and (ContratoTaskRangeTo <> ''):
                SourceContratoTask.SetRange("Contrato Task No.", ContratoTaskRangeFrom, ContratoTaskRangeTo);
            (ContratoTaskRangeFrom <> '') and (ContratoTaskRangeTo = ''):
                SourceContratoTask.SetFilter("Contrato Task No.", '%1..', ContratoTaskRangeFrom);
            (ContratoTaskRangeFrom = '') and (ContratoTaskRangeTo <> ''):
                SourceContratoTask.SetFilter("Contrato Task No.", '..%1', ContratoTaskRangeTo);
        end;
        OnCopyContratoTasksOnAfterSourceContratoTaskSetFilters(SourceContratoTask, SourceContrato);

        if SourceContratoTask.FindSet() then
            repeat
                TargetContratoTask.Init();
                TargetContratoTask.Validate("Contrato No.", TargetContrato."No.");
                TargetContratoTask.Validate("Contrato Task No.", SourceContratoTask."Contrato Task No.");
                TargetContratoTask.TransferFields(SourceContratoTask, false);
                if SourceContrato."Task Billing Method" = SourceContrato."Task Billing Method"::"Multiple customers" then begin
                    TargetContratoTask.SetHideValidationDialog(true);
                    TargetContratoTask.Validate("Sell-to Customer No.", '');
                end;
                if TargetContratoTask."WIP Method" <> '' then begin
                    TargetContratoTask.Validate("WIP-Total", TargetContratoTask."WIP-Total"::Total);
                    //TargetContratoTask.Validate("WIP Method", TargetContrato."WIP Method");
                end;
                TargetContratoTask.Validate("Recognized Sales Amount", 0);
                TargetContratoTask.Validate("Recognized Costs Amount", 0);
                TargetContratoTask.Validate("Recognized Sales G/L Amount", 0);
                TargetContratoTask.Validate("Recognized Costs G/L Amount", 0);
                IsHandled := false;
                OnCopyContratoTasksOnBeforeTargetContratoTaskInsert(TargetContratoTask, SourceContratoTask, IsHandled);
                if not IsHandled then
                    TargetContratoTask.Insert(true);
                case true of
                    ContratoPlanningLineSource = ContratoPlanningLineSource::"Contrato Planning Lines":
                        CopyContratoPlanningLines(SourceContratoTask, TargetContratoTask);
                    ContratoPlanningLineSource = ContratoPlanningLineSource::"Contrato Ledger Entries":
                        CopyJLEsToContratoPlanningLines(SourceContratoTask, TargetContratoTask);
                end;
                if CopyDimensions then
                    CopyContratoTaskDimensions(SourceContratoTask, TargetContratoTask);
                OnAfterCopyContratoTask(TargetContratoTask, SourceContratoTask, CopyPrices, CopyQuantity);
            until SourceContratoTask.Next() = 0;
    end;

    procedure CopyContratoPlanningLines(SourceContratoTask: Record "Contrato Task"; TargetContratoTask: Record "Contrato Task")
    var
        SourceContratoPlanningLine: Record "Contrato Planning Line";
        TargetContratoPlanningLine: Record "Contrato Planning Line";
        SourceContrato: Record Contrato;
        NextPlanningLineNo: Integer;
        IsHandled: Boolean;
    begin
        SourceContrato.Get(SourceContratoTask."Contrato No.");

        case true of
            (ContratoTaskDateRangeFrom <> 0D) and (ContratoTaskDateRangeTo <> 0D):
                SourceContratoTask.SetRange("Planning Date Filter", ContratoTaskDateRangeFrom, ContratoTaskDateRangeTo);
            (ContratoTaskDateRangeFrom <> 0D) and (ContratoTaskDateRangeTo = 0D):
                SourceContratoTask.SetFilter("Planning Date Filter", '%1..', ContratoTaskDateRangeFrom);
            (ContratoTaskDateRangeFrom = 0D) and (ContratoTaskDateRangeTo <> 0D):
                SourceContratoTask.SetFilter("Planning Date Filter", '..%1', ContratoTaskDateRangeTo);
        end;

        SourceContratoPlanningLine.SetRange("Contrato No.", SourceContratoTask."Contrato No.");
        SourceContratoPlanningLine.SetRange("Contrato Task No.", SourceContratoTask."Contrato Task No.");
        case ContratoPlanningLineType of
            ContratoPlanningLineType::Budget:
                SourceContratoPlanningLine.SetRange("Line Type", SourceContratoPlanningLine."Line Type"::Budget);
            ContratoPlanningLineType::Billable:
                SourceContratoPlanningLine.SetRange("Line Type", SourceContratoPlanningLine."Line Type"::Billable);
        end;
        SourceContratoPlanningLine.SetFilter("Planning Date", SourceContratoTask.GetFilter("Planning Date Filter"));
        if not SourceContratoPlanningLine.FindLast() then
            exit;
        NextPlanningLineNo := 0;
        SourceContratoPlanningLine.SetRange("Line No.", 0, SourceContratoPlanningLine."Line No.");
        OnCopyContratoPlanningLinesOnAfterSourceContratoPlanningLineSetFilters(SourceContratoPlanningLine);
        if SourceContratoPlanningLine.FindSet() then
            repeat
                IsHandled := false;
                OnCopyContratoPlanningLinesOnBeforeTargetContratoPlanningLineInit(TargetContratoPlanningLine, SourceContratoPlanningLine, TargetContratoTask, IsHandled);
                if not IsHandled then begin
                    TargetContratoPlanningLine.Init();
                    TargetContratoPlanningLine.Validate("Contrato No.", TargetContratoTask."Contrato No.");
                    TargetContratoPlanningLine.Validate("Contrato Task No.", TargetContratoTask."Contrato Task No.");
                    if NextPlanningLineNo = 0 then
                        NextPlanningLineNo := FindLastContratoPlanningLine(TargetContratoPlanningLine);
                    NextPlanningLineNo += 10000;
                    TargetContratoPlanningLine.Validate("Line No.", NextPlanningLineNo);
                    TargetContratoPlanningLine.TransferFields(SourceContratoPlanningLine, false);
                    if not CopyPrices then
                        TargetContratoPlanningLine.UpdateAllAmounts();

                    TargetContratoPlanningLine."Remaining Qty." := 0;
                    TargetContratoPlanningLine."Remaining Qty. (Base)" := 0;
                    TargetContratoPlanningLine."Remaining Total Cost" := 0;
                    TargetContratoPlanningLine."Remaining Total Cost (LCY)" := 0;
                    TargetContratoPlanningLine."Remaining Line Amount" := 0;
                    TargetContratoPlanningLine."Remaining Line Amount (LCY)" := 0;
                    TargetContratoPlanningLine."Qty. Posted" := 0;
                    TargetContratoPlanningLine."Qty. to Transfer to Journal" := 0;
                    TargetContratoPlanningLine."Posted Total Cost" := 0;
                    TargetContratoPlanningLine."Posted Total Cost (LCY)" := 0;
                    TargetContratoPlanningLine."Posted Line Amount" := 0;
                    TargetContratoPlanningLine."Posted Line Amount (LCY)" := 0;
                    TargetContratoPlanningLine."Qty. to Transfer to Invoice" := 0;
                    TargetContratoPlanningLine."Qty. to Invoice" := 0;
                    TargetContratoPlanningLine."Ledger Entry No." := 0;
                    TargetContratoPlanningLine."Ledger Entry Type" := TargetContratoPlanningLine."Ledger Entry Type"::" ";
                    OnCopyContratoPlanningLinesOnBeforeTargetContratoPlanningLineInsert(TargetContratoPlanningLine, SourceContratoPlanningLine);
                    TargetContratoPlanningLine.Insert(true);
                    OnCopyContratoPlanningLinesOnAfterTargetContratoPlanningLineInsert(TargetContratoPlanningLine, SourceContratoPlanningLine);
                    if TargetContratoPlanningLine.Type <> TargetContratoPlanningLine.Type::Text then begin
                        ExchangeContratoPlanningLineAmounts(TargetContratoPlanningLine, SourceContrato."Currency Code");
                        if not CopyQuantity then
                            TargetContratoPlanningLine.Validate(Quantity, 0)
                        else
                            TargetContratoPlanningLine.Validate(Quantity);
                        OnCopyContratoPlanningLinesOnBeforeModifyTargetContratoPlanningLine(TargetContratoPlanningLine);
                        TargetContratoPlanningLine.Modify();
                    end;
                end;
                OnCopyContratoPlanningLinesOnAfterCopyTargetContratoPlanningLine(TargetContratoPlanningLine, SourceContratoPlanningLine);
            until SourceContratoPlanningLine.Next() = 0;
    end;

    local procedure CopyJLEsToContratoPlanningLines(SourceContratoTask: Record "Contrato Task"; TargetContratoTask: Record "Contrato Task")
    var
        TargetContratoPlanningLine: Record "Contrato Planning Line";
        ContratoLedgEntry: Record "Contrato Ledger Entry";
        SourceContrato: Record Contrato;
        ContratoTransferLine: Codeunit "Contrato Transfer Line";
        NextPlanningLineNo: Integer;
    begin
        SourceContrato.Get(SourceContratoTask."Contrato No.");
        TargetContratoPlanningLine.SetRange("Contrato No.", TargetContratoTask."Contrato No.");
        TargetContratoPlanningLine.SetRange("Contrato Task No.", TargetContratoTask."Contrato Task No.");
        if TargetContratoPlanningLine.FindLast() then
            NextPlanningLineNo := TargetContratoPlanningLine."Line No." + 10000
        else
            NextPlanningLineNo := 10000;

        ContratoLedgEntry.SetRange("Contrato No.", SourceContratoTask."Contrato No.");
        ContratoLedgEntry.SetRange("Contrato Task No.", SourceContratoTask."Contrato Task No.");
        case true of
            ContratoLedgerEntryType = ContratoLedgerEntryType::Usage:
                ContratoLedgEntry.SetRange("Entry Type", ContratoLedgEntry."Entry Type"::Usage);
            ContratoLedgerEntryType = ContratoLedgerEntryType::Sale:
                ContratoLedgEntry.SetRange("Entry Type", ContratoLedgEntry."Entry Type"::Sale);
        end;
        ContratoLedgEntry.SetFilter("Posting Date", SourceContratoTask.GetFilter("Planning Date Filter"));
        if ContratoLedgEntry.FindSet() then
            repeat
                TargetContratoPlanningLine.Init();
                ContratoTransferLine.FromContratoLedgEntryToPlanningLine(ContratoLedgEntry, TargetContratoPlanningLine);
                TargetContratoPlanningLine."Contrato No." := TargetContratoTask."Contrato No.";
                TargetContratoPlanningLine.Validate("Line No.", NextPlanningLineNo);
                TargetContratoPlanningLine.Insert(true);
                if ContratoLedgEntry."Entry Type" = ContratoLedgEntry."Entry Type"::Usage then
                    TargetContratoPlanningLine.Validate("Line Type", TargetContratoPlanningLine."Line Type"::Budget)
                else begin
                    TargetContratoPlanningLine.Validate("Line Type", TargetContratoPlanningLine."Line Type"::Billable);
                    TargetContratoPlanningLine.Validate(Quantity, -ContratoLedgEntry.Quantity);
                    TargetContratoPlanningLine.Validate("Unit Cost (LCY)", ContratoLedgEntry."Unit Cost (LCY)");
                    TargetContratoPlanningLine.Validate("Unit Price (LCY)", ContratoLedgEntry."Unit Price (LCY)");
                    TargetContratoPlanningLine.Validate("Line Discount %", ContratoLedgEntry."Line Discount %");
                end;
                ExchangeContratoPlanningLineAmounts(TargetContratoPlanningLine, SourceContrato."Currency Code");
                if not CopyQuantity then
                    TargetContratoPlanningLine.Validate(Quantity, 0);
                NextPlanningLineNo += 10000;
                TargetContratoPlanningLine.Modify();
            until ContratoLedgEntry.Next() = 0;
    end;

    local procedure CopyContratoDimensions(SourceContrato: Record Contrato; var TargetContrato: Record Contrato)
    var
        DefaultDimension: Record "Default Dimension";
        NewDefaultDimension: Record "Default Dimension";
        DimMgt: Codeunit DimensionManagement;
    begin
        DefaultDimension.SetRange("Table ID", DATABASE::Contrato);
        DefaultDimension.SetRange("No.", TargetContrato."No.");
        if DefaultDimension.FindSet() then
            repeat
                DimMgt.DefaultDimOnDelete(DefaultDimension);
                DefaultDimension.Delete();
            until DefaultDimension.Next() = 0;

        DefaultDimension.SetRange("No.", SourceContrato."No.");
        if DefaultDimension.FindSet() then
            repeat
                NewDefaultDimension.Init();
                NewDefaultDimension."Table ID" := DATABASE::Contrato;
                NewDefaultDimension."No." := TargetContrato."No.";
                NewDefaultDimension."Dimension Code" := DefaultDimension."Dimension Code";
                NewDefaultDimension.TransferFields(DefaultDimension, false);
                NewDefaultDimension.Insert();
                DimMgt.DefaultDimOnInsert(DefaultDimension);
            until DefaultDimension.Next() = 0;

        DimMgt.UpdateDefaultDim(
          DATABASE::Contrato, TargetContrato."No.", TargetContrato."Global Dimension 1 Code", TargetContrato."Global Dimension 2 Code");

        OnAfterCopyContratoDimensions(SourceContrato, TargetContrato);
    end;

    local procedure CopyContratoTaskDimensions(SourceContratoTask: Record "Contrato Task"; TargetContratoTask: Record "Contrato Task")
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        DimensionManagement.CopyJobTaskDimToJobTaskDim(SourceContratoTask."Contrato No.",
          SourceContratoTask."Contrato Task No.",
          TargetContratoTask."Contrato No.",
          TargetContratoTask."Contrato Task No.");

        OnAfterCopyContratoTaskDimensions(SourceContratoTask, TargetContratoTask);
    end;

    local procedure ExchangeContratoPlanningLineAmounts(var ContratoPlanningLine: Record "Contrato Planning Line"; CurrencyCode: Code[10])
    var
        Contrato: Record Contrato;
        CurrExchRate: Record "Currency Exchange Rate";
        Currency: Record Currency;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeExchangeContratoPlanningLineAmounts(ContratoPlanningLine, CurrencyCode, IsHandled);
        if IsHandled then
            exit;

        Contrato.Get(ContratoPlanningLine."Contrato No.");
        if CurrencyCode <> Contrato."Currency Code" then
            if (CurrencyCode = '') and (Contrato."Currency Code" <> '') then begin
                ContratoPlanningLine."Currency Code" := Contrato."Currency Code";
                ContratoPlanningLine.UpdateCurrencyFactor();
                Currency.Get(ContratoPlanningLine."Currency Code");
                Currency.TestField("Unit-Amount Rounding Precision");
                ContratoPlanningLine."Unit Cost" := Round(
                    CurrExchRate.ExchangeAmtLCYToFCY(
                      ContratoPlanningLine."Currency Date", ContratoPlanningLine."Currency Code",
                      ContratoPlanningLine."Unit Cost (LCY)", ContratoPlanningLine."Currency Factor"),
                    Currency."Unit-Amount Rounding Precision");
                ContratoPlanningLine."Unit Price" := Round(
                    CurrExchRate.ExchangeAmtLCYToFCY(
                      ContratoPlanningLine."Currency Date", ContratoPlanningLine."Currency Code",
                      ContratoPlanningLine."Unit Price (LCY)", ContratoPlanningLine."Currency Factor"),
                    Currency."Unit-Amount Rounding Precision");
                ContratoPlanningLine.Validate("Currency Date");
            end else
                if (CurrencyCode <> '') and (Contrato."Currency Code" = '') then begin
                    ContratoPlanningLine."Currency Code" := '';
                    ContratoPlanningLine."Currency Date" := 0D;
                    ContratoPlanningLine.UpdateCurrencyFactor();
                    ContratoPlanningLine."Unit Cost" := ContratoPlanningLine."Unit Cost (LCY)";
                    ContratoPlanningLine."Unit Price" := ContratoPlanningLine."Unit Price (LCY)";
                    ContratoPlanningLine.Validate("Currency Date");
                end else
                    if (CurrencyCode <> '') and (Contrato."Currency Code" <> '') then begin
                        ContratoPlanningLine."Currency Code" := Contrato."Currency Code";
                        ContratoPlanningLine.UpdateCurrencyFactor();
                        Currency.Get(ContratoPlanningLine."Currency Code");
                        Currency.TestField("Unit-Amount Rounding Precision");
                        ContratoPlanningLine."Unit Cost" := Round(
                            CurrExchRate.ExchangeAmtFCYToFCY(
                              ContratoPlanningLine."Currency Date", CurrencyCode,
                              ContratoPlanningLine."Currency Code", ContratoPlanningLine."Unit Cost"),
                            Currency."Unit-Amount Rounding Precision");
                        ContratoPlanningLine."Unit Price" := Round(
                            CurrExchRate.ExchangeAmtFCYToFCY(
                              ContratoPlanningLine."Currency Date", CurrencyCode,
                              ContratoPlanningLine."Currency Code", ContratoPlanningLine."Unit Price"),
                            Currency."Unit-Amount Rounding Precision");
                        ContratoPlanningLine.Validate("Currency Date");
                    end;
    end;

    procedure SetCopyQuantity(CopyQuantity2: Boolean)
    begin
        CopyQuantity := CopyQuantity2;
    end;

    procedure SetCopyPrices(CopyPrices2: Boolean)
    begin
        CopyPrices := CopyPrices2;
    end;

    procedure SetCopyContratoPlanningLineType(ContratoPlanningLineType2: Option " ",Budget,Billable)
    begin
        ContratoPlanningLineType := ContratoPlanningLineType2;
    end;

    procedure SetCopyOptions(CopyPrices2: Boolean; CopyQuantity2: Boolean; CopyDimensions2: Boolean; ContratoPlanningLineSource2: Option "Contrato Planning Lines","Contrato Ledger Entries"; ContratoPlanningLineType2: Option " ",Budget,Billable; ContratoLedgerEntryType2: Option " ",Usage,Sale)
    begin
        CopyPrices := CopyPrices2;
        CopyQuantity := CopyQuantity2;
        CopyDimensions := CopyDimensions2;
        ContratoPlanningLineSource := ContratoPlanningLineSource2;
        ContratoPlanningLineType := ContratoPlanningLineType2;
        ContratoLedgerEntryType := ContratoLedgerEntryType2;
    end;

    procedure SetContratoTaskRange(ContratoTaskRangeFrom2: Code[20]; ContratoTaskRangeTo2: Code[20])
    begin
        ContratoTaskRangeFrom := ContratoTaskRangeFrom2;
        ContratoTaskRangeTo := ContratoTaskRangeTo2;
    end;

    procedure SetContratoTaskDateRange(ContratoTaskDateRangeFrom2: Date; ContratoTaskDateRangeTo2: Date)
    begin
        ContratoTaskDateRangeFrom := ContratoTaskDateRangeFrom2;
        ContratoTaskDateRangeTo := ContratoTaskDateRangeTo2;
    end;

    local procedure FindLastContratoPlanningLine(ContratoPlanningLine: Record "Contrato Planning Line"): Integer
    begin
        ContratoPlanningLine.SetRange("Contrato No.", ContratoPlanningLine."Contrato No.");
        ContratoPlanningLine.SetRange("Contrato Task No.", ContratoPlanningLine."Contrato Task No.");
        if ContratoPlanningLine.FindLast() then
            exit(ContratoPlanningLine."Line No.");
        exit(0);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyContrato(var TargetContrato: Record Contrato; SourceContrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCopyContrato(SourceContrato: Record Contrato; TargetContratoNo: Code[20]; TargetContratoDescription: Text[100]; TargetContratoSellToCustomer: Code[20]; TargetContratoBillToCustomer: Code[20]; CopyDimensions: Boolean; CopyPrices: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExchangeContratoPlanningLineAmounts(var ContratoPlanningLine: Record "Contrato Planning Line"; CurrencyCode: Code[10]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyContratoTask(var TargetContratoTask: Record "Contrato Task"; SourceContratoTask: Record "Contrato Task"; CopyPrices: Boolean; CopyQuantity: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyContratoDimensions(SourceContrato: Record Contrato; var TargetContrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyContratoTaskDimensions(SourceContratoTask: Record "Contrato Task"; TargetContratoTask: Record "Contrato Task")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyContratoPrices(var SourceContrato: Record Contrato; var TargetContrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCopyContratoTasks(var SourceContrato: Record Contrato; var TargetContrato: Record Contrato; var IsHandled: Boolean; CopyDimensions: Boolean; CopyQuantity: Boolean; CopyPrices: Boolean; ContratoTaskRangeFrom: Code[20]; ContratoTaskRangeTo: Code[20]; ContratoPlanningLineSource: Option; ContratoLedgerEntryType: Option)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyContratoPlanningLinesOnBeforeModifyTargetContratoPlanningLine(var TargetContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyContratoPlanningLinesOnAfterCopyTargetContratoPlanningLine(var TargetContratoPlanningLine: Record "Contrato Planning Line"; SourceContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyContratoPlanningLinesOnAfterSourceContratoPlanningLineSetFilters(var SourceContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyContratoPlanningLinesOnAfterTargetContratoPlanningLineInsert(var TargetContratoPlanningLine: Record "Contrato Planning Line"; SourceContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyContratoPlanningLinesOnBeforeTargetContratoPlanningLineInsert(var TargetContratoPlanningLine: Record "Contrato Planning Line"; SourceContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyContratoTasksOnBeforeTargetContratoTaskInsert(var TargetContratoTask: Record "Contrato Task"; SourceContratoTask: Record "Contrato Task"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyContratoTasksOnAfterSourceContratoTaskSetFilters(var SourceContratoTask: Record "Contrato Task"; SourceContrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnCopyContratoPlanningLinesOnBeforeTargetContratoPlanningLineInit(var TargetContratoPlanningLine: Record "Contrato Planning Line"; SourceContratoPlanningLine: Record "Contrato Planning Line"; TargetContratoTask: Record "Contrato Task"; var IsHandled: Boolean);
    begin
    end;
}

