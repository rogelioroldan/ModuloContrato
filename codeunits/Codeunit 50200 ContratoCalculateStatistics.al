codeunit 50200 "Contrato Calculate Statistics"
{

    trigger OnRun()
    begin
    end;

    var
        ContratoLedgEntry: Record "Contrato Ledger Entry";
        ContratoLedgEntry2: Record "Contrato Ledger Entry";
        ContratoPlanningLine: Record "Contrato Planning Line";
        ContratoPlanningLine2: Record "Contrato Planning Line";
        AmountType: Option TotalCostLCY,LineAmountLCY,TotalCost,LineAmount;
        PlanLineType: Option Schedule,Contract;
        ContratoLedgAmounts: array[10, 4, 4] of Decimal;
        ContratoPlanAmounts: array[10, 4, 4] of Decimal;
        HeadlineTxt: Label 'Budget Price,Usage Price,Billable Price,Invoiced Price,Budget Cost,Usage Cost,Billable Cost,Invoiced Cost,Budget Profit,Usage Profit,Billable Profit,Invoiced Profit';

    procedure ReportAnalysis(var Contrato2: Record Contrato; var JT: Record "Contrato Task"; var Amt: array[8] of Decimal; AmountField: array[8] of Option " ",SchPrice,UsagePrice,ContractPrice,InvoicedPrice,SchCost,UsageCost,ContractCost,InvoicedCost,SchProfit,UsageProfit,ContractProfit,InvoicedProfit; CurrencyField: array[8] of Option LCY,FCY; ContratoLevel: Boolean)
    var
        PL: array[16] of Decimal;
        CL: array[16] of Decimal;
        P: array[16] of Decimal;
        C: array[16] of Decimal;
        I: Integer;
    begin
        if ContratoLevel then
            ContratoCalculateCommonFilters(Contrato2)
        else
            JTCalculateCommonFilters(JT, Contrato2, true);
        CalculateAmounts();
        GetLCYCostAmounts(CL);
        GetCostAmounts(C);
        GetLCYPriceAmounts(PL);
        GetPriceAmounts(P);

        OnReportAnalysisOnAfterGetAmounts(PL, CL, P, C, I);

        Clear(Amt);
        for I := 1 to 8 do begin
            if AmountField[I] = AmountField[I] ::SchPrice then
                if CurrencyField[I] = CurrencyField[I] ::LCY then
                    Amt[I] := PL[4]
                else
                    Amt[I] := P[4];
            if AmountField[I] = AmountField[I] ::UsagePrice then
                if CurrencyField[I] = CurrencyField[I] ::LCY then
                    Amt[I] := PL[8]
                else
                    Amt[I] := P[8];
            if AmountField[I] = AmountField[I] ::ContractPrice then
                if CurrencyField[I] = CurrencyField[I] ::LCY then
                    Amt[I] := PL[12]
                else
                    Amt[I] := P[12];
            if AmountField[I] = AmountField[I] ::InvoicedPrice then
                if CurrencyField[I] = CurrencyField[I] ::LCY then
                    Amt[I] := PL[16]
                else
                    Amt[I] := P[16];

            if AmountField[I] = AmountField[I] ::SchCost then
                if CurrencyField[I] = CurrencyField[I] ::LCY then
                    Amt[I] := CL[4]
                else
                    Amt[I] := C[4];
            if AmountField[I] = AmountField[I] ::UsageCost then
                if CurrencyField[I] = CurrencyField[I] ::LCY then
                    Amt[I] := CL[8]
                else
                    Amt[I] := C[8];
            if AmountField[I] = AmountField[I] ::ContractCost then
                if CurrencyField[I] = CurrencyField[I] ::LCY then
                    Amt[I] := CL[12]
                else
                    Amt[I] := C[12];
            if AmountField[I] = AmountField[I] ::InvoicedCost then
                if CurrencyField[I] = CurrencyField[I] ::LCY then
                    Amt[I] := CL[16]
                else
                    Amt[I] := C[16];

            if AmountField[I] = AmountField[I] ::SchProfit then
                if CurrencyField[I] = CurrencyField[I] ::LCY then
                    Amt[I] := PL[4] - CL[4]
                else
                    Amt[I] := P[4] - C[4];
            if AmountField[I] = AmountField[I] ::UsageProfit then
                if CurrencyField[I] = CurrencyField[I] ::LCY then
                    Amt[I] := PL[8] - CL[8]
                else
                    Amt[I] := P[8] - C[8];
            if AmountField[I] = AmountField[I] ::ContractProfit then
                if CurrencyField[I] = CurrencyField[I] ::LCY then
                    Amt[I] := PL[12] - CL[12]
                else
                    Amt[I] := P[12] - C[12];
            if AmountField[I] = AmountField[I] ::InvoicedProfit then
                if CurrencyField[I] = CurrencyField[I] ::LCY then
                    Amt[I] := PL[16] - CL[16]
                else
                    Amt[I] := P[16] - C[16];
        end;

        OnAfterReportAnalysis(AmountField, CurrencyField, Amt);
    end;

    procedure ReportSuggBilling(var Contrato2: Record Contrato; var JT: Record "Contrato Task"; var Amt: array[8] of Decimal; CurrencyField: array[8] of Option LCY,FCY)
    var
        AmountField: array[8] of Option " ",SchPrice,UsagePrice,ContractPrice,InvoicedPrice,SchCost,UsageCost,ContractCost,InvoicedCost,SchProfit,UsageProfit,ContractProfit,InvoicedProfit;
    begin
        AmountField[1] := AmountField[1] ::ContractCost;
        AmountField[2] := AmountField[2] ::ContractPrice;
        AmountField[3] := AmountField[3] ::InvoicedCost;
        AmountField[4] := AmountField[4] ::InvoicedPrice;
        ReportAnalysis(Contrato2, JT, Amt, AmountField, CurrencyField, false);
        Amt[5] := Amt[1] - Amt[3];
        Amt[6] := Amt[2] - Amt[4];
    end;

    procedure RepContratoCustomer(var Contrato2: Record Contrato; var Amt: array[8] of Decimal)
    var
        JT: Record "Contrato Task";
        AmountField: array[8] of Option " ",SchPrice,UsagePrice,ContractPrice,InvoicedPrice,SchCost,UsageCost,ContractCost,InvoicedCost,SchProfit,UsageProfit,ContractProfit,InvoicedProfit;
        CurrencyField: array[8] of Option LCY,FCY;
    begin
        Clear(Amt);
        if Contrato2."No." = '' then
            exit;
        AmountField[1] := AmountField[1] ::SchPrice;
        AmountField[2] := AmountField[2] ::UsagePrice;
        AmountField[3] := AmountField[3] ::InvoicedPrice;
        AmountField[4] := AmountField[4] ::ContractPrice;
        ReportAnalysis(Contrato2, JT, Amt, AmountField, CurrencyField, true);
        Amt[5] := 0;
        Amt[6] := 0;
        if Amt[1] <> 0 then
            Amt[5] := Round(Amt[2] / Amt[1] * 100);
        if Amt[4] <> 0 then
            Amt[6] := Round(Amt[3] / Amt[4] * 100);
    end;

    procedure ContratoCalculateCommonFilters(var Contrato: Record Contrato)
    begin
        ClearAll();
        ContratoPlanningLine.SetCurrentKey("Contrato No.", "Contrato Task No.");
        ContratoLedgEntry.SetCurrentKey("Contrato No.", "Contrato Task No.", "Entry Type");
        ContratoPlanningLine.FilterGroup(2);
        ContratoLedgEntry.SetRange("Contrato No.", Contrato."No.");
        ContratoPlanningLine.SetRange("Contrato No.", Contrato."No.");
        ContratoPlanningLine.FilterGroup(0);
        ContratoLedgEntry.SetFilter("Posting Date", Contrato.GetFilter("Posting Date Filter"));
        ContratoPlanningLine.SetFilter("Planning Date", Contrato.GetFilter("Planning Date Filter"));

        OnAfterContratoCalculateCommonFilters(Contrato, ContratoLedgEntry, ContratoPlanningLine);
    end;

    procedure JTCalculateCommonFilters(var JT2: Record "Contrato Task"; var Contrato2: Record Contrato; UseContratoFilter: Boolean)
    var
        JT: Record "Contrato Task";
    begin
        ClearAll();
        JT := JT2;
        ContratoPlanningLine.FilterGroup(2);
        ContratoPlanningLine.SetCurrentKey("Contrato No.", "Contrato Task No.");
        ContratoLedgEntry.SetCurrentKey("Contrato No.", "Contrato Task No.", "Entry Type");
        ContratoLedgEntry.SetRange("Contrato No.", JT."Contrato No.");
        ContratoPlanningLine.SetRange("Contrato No.", JT."Contrato No.");
        ContratoPlanningLine.FilterGroup(0);
        if JT."Contrato Task No." <> '' then
            if JT.Totaling <> '' then begin
                ContratoLedgEntry.SetFilter("Contrato Task No.", JT.Totaling);
                ContratoPlanningLine.SetFilter("Contrato Task No.", JT.Totaling);
            end else begin
                ContratoLedgEntry.SetRange("Contrato Task No.", JT."Contrato Task No.");
                ContratoPlanningLine.SetRange("Contrato Task No.", JT."Contrato Task No.");
            end;

        if not UseContratoFilter then begin
            ContratoLedgEntry.SetFilter("Posting Date", JT2.GetFilter("Posting Date Filter"));
            ContratoPlanningLine.SetFilter("Planning Date", JT2.GetFilter("Planning Date Filter"));
        end else begin
            ContratoLedgEntry.SetFilter("Posting Date", Contrato2.GetFilter("Posting Date Filter"));
            ContratoPlanningLine.SetFilter("Planning Date", Contrato2.GetFilter("Planning Date Filter"));
        end;

        OnAfterJTCalculateCommonFilters(JT, JT2, Contrato2, UseContratoFilter, ContratoLedgEntry, ContratoPlanningLine);
    end;

    procedure CalculateAmounts()
    begin
        CalcContratoLedgAmounts(ContratoLedgEntry."Entry Type"::Usage, ContratoLedgEntry.Type::Resource);
        CalcContratoLedgAmounts(ContratoLedgEntry."Entry Type"::Usage, ContratoLedgEntry.Type::Item);
        CalcContratoLedgAmounts(ContratoLedgEntry."Entry Type"::Usage, ContratoLedgEntry.Type::"G/L Account");
        CalcContratoLedgAmounts(ContratoLedgEntry."Entry Type"::Sale, ContratoLedgEntry.Type::Resource);
        CalcContratoLedgAmounts(ContratoLedgEntry."Entry Type"::Sale, ContratoLedgEntry.Type::Item);
        CalcContratoLedgAmounts(ContratoLedgEntry."Entry Type"::Sale, ContratoLedgEntry.Type::"G/L Account");

        CalcContratoPlanAmounts(PlanLineType::Contract, ContratoPlanningLine.Type::Resource);
        CalcContratoPlanAmounts(PlanLineType::Contract, ContratoPlanningLine.Type::Item);
        CalcContratoPlanAmounts(PlanLineType::Contract, ContratoPlanningLine.Type::"G/L Account");
        CalcContratoPlanAmounts(PlanLineType::Schedule, ContratoPlanningLine.Type::Resource);
        CalcContratoPlanAmounts(PlanLineType::Schedule, ContratoPlanningLine.Type::Item);
        CalcContratoPlanAmounts(PlanLineType::Schedule, ContratoPlanningLine.Type::"G/L Account");
    end;

    local procedure CalcContratoLedgAmounts(EntryType: Enum ContratoJournalLineEntryType; TypeParm: Enum "Contrato Planning Line Type")
    begin
        ContratoLedgEntry2.Copy(ContratoLedgEntry);
        ContratoLedgEntry2.SetRange("Entry Type", EntryType);
        ContratoLedgEntry2.SetRange(Type, TypeParm);
        ContratoLedgEntry2.CalcSums("Total Cost (LCY)", "Line Amount (LCY)", "Total Cost", "Line Amount");
        ContratoLedgAmounts[1 + EntryType.AsInteger(), 1 + TypeParm.AsInteger(), 1 + AmountType::TotalCostLCY] := ContratoLedgEntry2."Total Cost (LCY)";
        ContratoLedgAmounts[1 + EntryType.AsInteger(), 1 + TypeParm.AsInteger(), 1 + AmountType::LineAmountLCY] := ContratoLedgEntry2."Line Amount (LCY)";
        ContratoLedgAmounts[1 + EntryType.AsInteger(), 1 + TypeParm.AsInteger(), 1 + AmountType::TotalCost] := ContratoLedgEntry2."Total Cost";
        ContratoLedgAmounts[1 + EntryType.AsInteger(), 1 + TypeParm.AsInteger(), 1 + AmountType::LineAmount] := ContratoLedgEntry2."Line Amount";
    end;

    local procedure CalcContratoPlanAmounts(PlanLineTypeParm: Option; TypeParm: Enum "Contrato Planning Line Type")
    begin
        ContratoPlanningLine2.Copy(ContratoPlanningLine);
        ContratoPlanningLine2.SetRange("Schedule Line");
        ContratoPlanningLine2.SetRange("Contract Line");
        if PlanLineTypeParm = PlanLineType::Schedule then
            ContratoPlanningLine2.SetRange("Schedule Line", true)
        else
            ContratoPlanningLine2.SetRange("Contract Line", true);
        ContratoPlanningLine2.SetRange(Type, TypeParm);
        OnCalcContratoPlanAmountsOnAfterContratoPlanningLineSetFilters(ContratoPlanningLine2);

        ContratoPlanningLine2.CalcSums("Total Cost (LCY)", "Line Amount (LCY)", "Total Cost", "Line Amount");
        ContratoPlanAmounts[1 + PlanLineTypeParm, 1 + TypeParm.AsInteger(), 1 + AmountType::TotalCostLCY] := ContratoPlanningLine2."Total Cost (LCY)";
        ContratoPlanAmounts[1 + PlanLineTypeParm, 1 + TypeParm.AsInteger(), 1 + AmountType::LineAmountLCY] := ContratoPlanningLine2."Line Amount (LCY)";
        ContratoPlanAmounts[1 + PlanLineTypeParm, 1 + TypeParm.AsInteger(), 1 + AmountType::TotalCost] := ContratoPlanningLine2."Total Cost";
        ContratoPlanAmounts[1 + PlanLineTypeParm, 1 + TypeParm.AsInteger(), 1 + AmountType::LineAmount] := ContratoPlanningLine2."Line Amount";
    end;

    procedure GetLCYCostAmounts(var Amt: array[16] of Decimal)
    begin
        GetArrayAmounts(Amt, AmountType::TotalCostLCY);
    end;

    procedure GetCostAmounts(var Amt: array[16] of Decimal)
    begin
        GetArrayAmounts(Amt, AmountType::TotalCost);
    end;

    procedure GetLCYPriceAmounts(var Amt: array[16] of Decimal)
    begin
        GetArrayAmounts(Amt, AmountType::LineAmountLCY);
    end;

    procedure GetPriceAmounts(var Amt: array[16] of Decimal)
    begin
        GetArrayAmounts(Amt, AmountType::LineAmount);
    end;

    local procedure GetArrayAmounts(var Amt: array[16] of Decimal; AmountTypeParm: Option)
    begin
        Amt[1] := ContratoPlanAmounts[1 + PlanLineType::Schedule, 1 + ContratoPlanningLine.Type::Resource.AsInteger(), 1 + AmountTypeParm];
        Amt[2] := ContratoPlanAmounts[1 + PlanLineType::Schedule, 1 + ContratoPlanningLine.Type::Item.AsInteger(), 1 + AmountTypeParm];
        Amt[3] := ContratoPlanAmounts[1 + PlanLineType::Schedule, 1 + ContratoPlanningLine.Type::"G/L Account".AsInteger(), 1 + AmountTypeParm];
        Amt[4] := Amt[1] + Amt[2] + Amt[3];
        Amt[5] := ContratoLedgAmounts[1 + ContratoLedgEntry."Entry Type"::Usage.AsInteger(), 1 + ContratoLedgEntry.Type::Resource.AsInteger(), 1 + AmountTypeParm];
        Amt[6] := ContratoLedgAmounts[1 + ContratoLedgEntry."Entry Type"::Usage.AsInteger(), 1 + ContratoLedgEntry.Type::Item.AsInteger(), 1 + AmountTypeParm];
        Amt[7] := ContratoLedgAmounts[1 + ContratoLedgEntry."Entry Type"::Usage.AsInteger(), 1 + ContratoLedgEntry.Type::"G/L Account".AsInteger(), 1 + AmountTypeParm];
        Amt[8] := Amt[5] + Amt[6] + Amt[7];
        Amt[9] := ContratoPlanAmounts[1 + PlanLineType::Contract, 1 + ContratoPlanningLine.Type::Resource.AsInteger(), 1 + AmountTypeParm];
        Amt[10] := ContratoPlanAmounts[1 + PlanLineType::Contract, 1 + ContratoPlanningLine.Type::Item.AsInteger(), 1 + AmountTypeParm];
        Amt[11] := ContratoPlanAmounts[1 + PlanLineType::Contract, 1 + ContratoPlanningLine.Type::"G/L Account".AsInteger(), 1 + AmountTypeParm];
        Amt[12] := Amt[9] + Amt[10] + Amt[11];
        Amt[13] := -ContratoLedgAmounts[1 + ContratoLedgEntry."Entry Type"::Sale.AsInteger(), 1 + ContratoLedgEntry.Type::Resource.AsInteger(), 1 + AmountTypeParm];
        Amt[14] := -ContratoLedgAmounts[1 + ContratoLedgEntry."Entry Type"::Sale.AsInteger(), 1 + ContratoLedgEntry.Type::Item.AsInteger(), 1 + AmountTypeParm];
        Amt[15] := -ContratoLedgAmounts[1 + ContratoLedgEntry."Entry Type"::Sale.AsInteger(), 1 + ContratoLedgEntry.Type::"G/L Account".AsInteger(), 1 + AmountTypeParm];
        Amt[16] := Amt[13] + Amt[14] + Amt[15];
    end;

    procedure ShowPlanningLine(ContratoType: Option " ",Resource,Item,GL; Schedule: Boolean)
    begin
        ContratoPlanningLine.FilterGroup(2);
        ContratoPlanningLine.SetRange("Contract Line");
        ContratoPlanningLine.SetRange("Schedule Line");
        ContratoPlanningLine.SetRange(Type);
        if ContratoType > 0 then
            ContratoPlanningLine.SetRange(Type, ContratoType - 1);
        if Schedule then
            ContratoPlanningLine.SetRange("Schedule Line", true)
        else
            ContratoPlanningLine.SetRange("Contract Line", true);
        ContratoPlanningLine.FilterGroup(0);
        OnShowPlanningLineOnAfterContratoPlanningLineSetFilters(ContratoPlanningLine);
        PAGE.Run(PAGE::"Contrato Planning Lines", ContratoPlanningLine);
    end;

    procedure ShowLedgEntry(ContratoType: Option " ",Resource,Item,GL; Usage: Boolean)
    var
        ContratoLedgerEntries: Page "Contrato Ledger Entries";
    begin
        ContratoLedgEntry.SetRange(Type);
        if Usage then
            ContratoLedgEntry.SetRange("Entry Type", ContratoLedgEntry."Entry Type"::Usage)
        else
            ContratoLedgEntry.SetRange("Entry Type", ContratoLedgEntry."Entry Type"::Sale);
        if ContratoType > 0 then
            ContratoLedgEntry.SetRange(Type, ContratoType - 1);
        Clear(ContratoLedgerEntries);
        ContratoLedgerEntries.SetTableView(ContratoLedgEntry);
        ContratoLedgerEntries.Run();
    end;

    procedure GetHeadLineText(AmountField: array[8] of Option " ",SchPrice,UsagePrice,BillablePrice,InvoicedPrice,SchCost,UsageCost,BillableCost,InvoicedCost,SchProfit,UsageProfit,BillableProfit,InvoicedProfit; CurrencyField: array[8] of Option LCY,FCY; var HeadLineText: array[8] of Text[50]; Contrato: Record Contrato)
    var
        GLSetup: Record "General Ledger Setup";
        I: Integer;
        Txt: Text[30];
    begin
        Clear(HeadLineText);
        GLSetup.Get();

        for I := 1 to 8 do begin
            Txt := '';
            if CurrencyField[I] > 0 then
                Txt := Contrato."Currency Code";
            if Txt = '' then
                Txt := GLSetup."LCY Code";
            if AmountField[I] > 0 then
                HeadLineText[I] := SelectStr(AmountField[I], HeadlineTxt) + '\' + Txt;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterContratoCalculateCommonFilters(var Contrato: Record Contrato; var ContratoLedgerEntry: Record "Contrato Ledger Entry"; var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterJTCalculateCommonFilters(ContratoTask: Record "Contrato Task"; var ContratoTask2: Record "Contrato Task"; var Contrato2: Record Contrato; UseContratoFilter: Boolean; var ContratoLedgerEntry: Record "Contrato Ledger Entry"; var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReportAnalysis(AmountField: array[8] of Option " ",SchPrice,UsagePrice,ContractPrice,InvoicedPrice,SchCost,UsageCost,ContractCost,InvoicedCost,SchProfit,UsageProfit,ContractProfit,InvoicedProfit; CurrencyField: array[8] of Option LCY,FCY; var Amt: array[8] of Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcContratoPlanAmountsOnAfterContratoPlanningLineSetFilters(var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReportAnalysisOnAfterGetAmounts(var PL: array[16] of Decimal; var CL: array[16] of Decimal; var P: array[16] of Decimal; var C: array[16] of Decimal; var I: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnShowPlanningLineOnAfterContratoPlanningLineSetFilters(var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;
}

