codeunit 50225 "Contrato Calculate WIP"
{
    Permissions = TableData "Contrato Ledger Entry" = rm,
                  TableData "Contrato Task" = rimd,
                  TableData "Contrato Planning Line" = r,
                  TableData "Contrato WIP Entry" = rimd,
                  TableData "Contrato WIP G/L Entry" = rimd;

    trigger OnRun()
    begin
    end;

    var
        TempContratoWIPBuffer: array[2] of Record "Contrato WIP Buffer" temporary;
        GLSetup: Record "General Ledger Setup";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnPostLine: Codeunit "Gen. Jnl.-Post Line";
        DimMgt: Codeunit DimensionManagement;
        ErrorMessageMgt: Codeunit "Error Message Management";
        ErrorContextElement: Codeunit "Error Context Element";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        WIPPostingDate: Date;
        DocNo: Code[20];
        Text001: Label 'WIP %1', Comment = 'WIP GUILDFORD, 10 CR';
        Text002: Label 'Recognition %1', Comment = 'Recognition GUILDFORD, 10 CR';
        Text003: Label 'Completion %1', Comment = 'Completion GUILDFORD, 10 CR';
        ContratoComplete: Boolean;
        Text004: Label 'WIP G/L entries posted for Project %1 cannot be reversed at an earlier date than %2.';
        Text005: Label '..%1';
        HasGotGLSetup: Boolean;
        ContratoWIPTotalChanged: Boolean;
        WIPAmount: Decimal;
        RecognizedAllocationPercentage: Decimal;
        CannotModifyAssociatedEntriesErr: Label 'The %1 cannot be modified because the project has associated project WIP entries.', Comment = '%1=The project task table name.';

    procedure ContratoCalcWIP(var Contrato: Record Contrato; WIPPostingDate2: Date; DocNo2: Code[20])
    var
        ContratoTask: Record "Contrato Task";
        ContratoLedgEntry: Record "Contrato Ledger Entry";
        ContratoLedgerEntry2: Record "Contrato Ledger Entry";
        ContratoPlanningLine: Record "Contrato Planning Line";
        ContratoWIPEntry: Record "Contrato WIP Entry";
        ContratoWIPGLEntry: Record "Contrato WIP G/L Entry";
        FromContratoTask: Code[20];
        First: Boolean;
    begin
        ClearAll();
        TempContratoWIPBuffer[1].DeleteAll();

        ContratoPlanningLine.LockTable();
        ContratoLedgEntry.LockTable();
        ContratoWIPEntry.LockTable();
        ContratoTask.LockTable();
        Contrato.LockTable();

        ContratoWIPGLEntry.SetCurrentKey("Contrato No.", Reversed, "Contrato Complete");
        ContratoWIPGLEntry.SetRange("Contrato No.", Contrato."No.");
        ContratoWIPGLEntry.SetRange("Contrato Complete", true);
        if ContratoWIPGLEntry.FindFirst() then begin
            ContratoWIPEntry.DeleteEntriesForContrato(Contrato);
            exit;
        end;

        if WIPPostingDate2 = 0D then
            WIPPostingDate := WorkDate()
        else
            WIPPostingDate := WIPPostingDate2;
        DocNo := DocNo2;

        ActivateErrorMessageHandling(Contrato);

        Contrato.TestBlocked();
        Contrato.TestField("WIP Method");
        Contrato."WIP Posting Date" := WIPPostingDate;
        if (Contrato."Ending Date" = 0D) and Contrato.Complete then
            Contrato.Validate("Ending Date", WIPPostingDate);
        ContratoComplete := Contrato.Complete and (WIPPostingDate >= Contrato."Ending Date");
        OnContratoCalcWIPOnBeforeContratoModify(Contrato, ContratoComplete);
        Contrato.Modify();

        DeleteWIP(Contrato);
        AssignWIPTotalAndMethodToContratoTask(ContratoTask, Contrato);
        First := true;
        if ContratoTask.Find('-') then
            repeat
                if First then
                    FromContratoTask := ContratoTask."Contrato Task No.";
                First := false;
                if ContratoTask."WIP-Total" = ContratoTask."WIP-Total"::Total then begin
                    ContratoTaskCalcWIP(Contrato, FromContratoTask, ContratoTask."Contrato Task No.");
                    First := true;
                    AssignWIPTotalAndMethodToRemainingContratoTask(ContratoTask, Contrato);
                    // Balance Contrato ledger entry when used quantity on a task is returned
                    if (ContratoTask."Recognized Sales Amount" = 0) and (ContratoTask."Recognized Sales G/L Amount" <> 0) then begin
                        ContratoLedgerEntry2.SetRange("Contrato No.", ContratoTask."Contrato No.");
                        ContratoLedgerEntry2.SetRange("Contrato Task No.", ContratoTask."Contrato Task No.");
                        ContratoLedgerEntry2.SetRange("Entry Type", ContratoLedgerEntry2."Entry Type"::Sale);
                        ContratoLedgerEntry2.SetLoadFields("Line Amount (LCY)", "Amt. to Post to G/L", "Amt. Posted to G/L");
                        if ContratoLedgerEntry2.FindSet(true) then
                            repeat
                                if (ContratoLedgerEntry2."Line Amount (LCY)" <> 0) and (ContratoLedgerEntry2."Amt. to Post to G/L" = 0) and (ContratoLedgerEntry2."Amt. Posted to G/L" = 0) then begin
                                    ContratoLedgerEntry2.Validate("Amt. to Post to G/L", ContratoLedgerEntry2."Line Amount (LCY)");
                                    ContratoLedgerEntry2.Modify(true);
                                end;
                            until ContratoLedgerEntry2.Next() = 0;
                    end;
                end;
            until ContratoTask.Next() = 0;
        CreateWIPEntries(Contrato."No.");

        if ErrorMessageHandler.HasErrors() then
            if ErrorMessageHandler.ShowErrors() then
                Error('');
    end;

    local procedure ActivateErrorMessageHandling(var Contrato: Record Contrato)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeActivateErrorMessageHandling(Contrato, ErrorMessageMgt, ErrorMessageHandler, ErrorContextElement, IsHandled);
        if IsHandled then
            exit;

        if GuiAllowed then begin
            ErrorMessageMgt.Activate(ErrorMessageHandler);
            ErrorMessageMgt.PushContext(ErrorContextElement, Contrato.RecordId, 0, '');
        end;
    end;

    procedure DeleteWIP(Contrato: Record Contrato)
    var
        ContratoTask: Record "Contrato Task";
        ContratoWIPEntry: Record "Contrato WIP Entry";
        ContratoLedgerEntry: Record "Contrato Ledger Entry";
    begin
        ContratoTask.SetRange("Contrato No.", Contrato."No.");
        if ContratoTask.Find('-') then
            repeat
                ContratoTask.InitWIPFields();
            until ContratoTask.Next() = 0;

        ContratoWIPEntry.DeleteEntriesForContrato(Contrato);

        ContratoLedgerEntry.SetRange("Contrato No.", Contrato."No.");
        ContratoLedgerEntry.ModifyAll("Amt. to Post to G/L", 0);
    end;

    local procedure ContratoTaskCalcWIP(var Contrato: Record Contrato; FromContratoTask: Code[20]; ToContratoTask: Code[20])
    var
        AccruedCostsContratoTask: Record "Contrato Task";
        AccruedCostsContratoWIPTotal: Record "Contrato WIP Total";
        ContratoTask: Record "Contrato Task";
        ContratoWIPTotal: Record "Contrato WIP Total";
        ContratoWIPWarning: Record "Contrato WIP Warning";
        RecognizedCostAmount: Decimal;
        UsageTotalCost: Decimal;
        IsHandled: Boolean;
    begin
        RecognizedCostAmount := 0;
        UsageTotalCost := 0;

        ContratoTask.SetRange("Contrato No.", Contrato."No.");
        ContratoTask.SetRange("Contrato Task No.", FromContratoTask, ToContratoTask);
        ContratoTask.SetFilter("WIP-Total", '<> %1', ContratoTask."WIP-Total"::Excluded);

        if Contrato.GetFilter("Posting Date Filter") <> '' then
            ContratoTask.SetFilter("Posting Date Filter", Contrato.GetFilter("Posting Date Filter"))
        else
            ContratoTask.SetFilter("Posting Date Filter", StrSubstNo(Text005, WIPPostingDate));

        ContratoTask.SetFilter("Planning Date Filter", Contrato.GetFilter("Planning Date Filter"));

        CreateContratoWIPTotal(ContratoTask, ContratoWIPTotal);

        if ContratoTask.Find('-') then
            repeat
                if ContratoTask."Contrato Task Type" = ContratoTask."Contrato Task Type"::Posting then begin
                    ContratoTask.CalcFields(
                      "Schedule (Total Cost)",
                      "Schedule (Total Price)",
                      "Usage (Total Cost)",
                      "Usage (Total Price)",
                      "Contract (Total Cost)",
                      "Contract (Total Price)",
                      "Contract (Invoiced Price)",
                      "Contract (Invoiced Cost)");

                    OnContratoTaskCalcWIPOnBeforeCalcWIP(ContratoTask);

                    CalcWIP(ContratoTask, ContratoWIPTotal);
                    ContratoTask.Modify();

                    ContratoWIPTotal."Calc. Recog. Costs Amount" += ContratoTask."Recognized Costs Amount";
                    ContratoWIPTotal."Calc. Recog. Sales Amount" += ContratoTask."Recognized Sales Amount";
                    IsHandled := false;
                    OnContratoTaskCalcWIPOnBeforeCreateTempContratoWIPBuffer(ContratoTask, ContratoWIPTotal, IsHandled);
                    if not IsHandled then
                        CreateTempContratoWIPBuffers(ContratoTask, ContratoWIPTotal);
                    if (ContratoTask."Recognized Costs Amount" <> 0) and (AccruedCostsContratoTask."Contrato Task No." = '') then begin
                        AccruedCostsContratoTask := ContratoTask;
                        AccruedCostsContratoWIPTotal := ContratoWIPTotal;
                    end;

                    IsHandled := false;
                    OnContratoTaskCalcWIPOnBeforeSumContratoTaskCosts(ContratoTask, RecognizedCostAmount, UsageTotalCost, IsHandled);
                    if not IsHandled then begin
                        RecognizedCostAmount += ContratoTask."Recognized Costs Amount";
                        UsageTotalCost += ContratoTask."Usage (Total Cost)";
                    end;

                    ContratoWIPTotalChanged := false;
                    WIPAmount := 0;
                end;
            until ContratoTask.Next() = 0;
        ContratoTaskCalcAccruedCostsWIP(Contrato, AccruedCostsContratoWIPTotal, AccruedCostsContratoTask, RecognizedCostAmount, UsageTotalCost);
        CalcCostInvoicePercentage(ContratoWIPTotal);
        OnContratoTaskCalcWIPOnBeforeContratoWIPTotalModify(Contrato, ContratoWIPTotal);
        ContratoWIPTotal.Modify();
        OnContratoTaskCalcWIPOnAfterContratoWIPTotalModify(Contrato, ContratoWIPTotal);
        ContratoWIPWarning.CreateEntries(ContratoWIPTotal);

        OnAfterContratoTaskCalcWIP(Contrato, FromContratoTask, ToContratoTask, ContratoWIPTotal);
    end;

    local procedure ContratoTaskCalcAccruedCostsWIP(Contrato: Record Contrato; AccruedCostsContratoWIPTotal: Record "Contrato WIP Total"; AccruedCostsContratoTask: Record "Contrato Task"; RecognizedCostAmount: Decimal; UsageTotalCost: Decimal)
    var
        ContratoWIPMethod: Record "Contrato WIP Method";
    begin
        if (not ContratoComplete) and (RecognizedCostAmount > UsageTotalCost) and (AccruedCostsContratoTask."Contrato Task No." <> '') then begin
            ContratoWIPMethod.Get(AccruedCostsContratoWIPTotal."WIP Method");
            InitWIPBufferEntryFromTask(
              AccruedCostsContratoTask, AccruedCostsContratoWIPTotal, Enum::"Contrato WIP Buffer Type"::"Accrued Costs",
              GetAccruedCostsAmount(ContratoWIPMethod, RecognizedCostAmount, UsageTotalCost));
            UpdateWIPBufferEntryFromTask(AccruedCostsContratoTask, AccruedCostsContratoWIPTotal);
            if Contrato."WIP Posting Method" = Contrato."WIP Posting Method"::"Per Contrato Ledger Entry" then begin
                InitWIPBufferEntryFromTask(
                  AccruedCostsContratoTask, AccruedCostsContratoWIPTotal, Enum::"Contrato WIP Buffer Type"::"Applied Costs",
                  GetAppliedCostsAmount(RecognizedCostAmount, UsageTotalCost, ContratoWIPMethod, true));
                UpdateWIPBufferEntryFromTask(AccruedCostsContratoTask, AccruedCostsContratoWIPTotal);
            end;
        end;
    end;

    local procedure CreateContratoWIPTotal(var ContratoTask: Record "Contrato Task"; var ContratoWIPTotal: Record "Contrato WIP Total")
    var
        IsHandled: Boolean;
    begin
        OnBeforeCreateContratoWIPTotal(ContratoTask);
        ContratoWIPTotalChanged := true;
        WIPAmount := 0;
        RecognizedAllocationPercentage := 0;

        ContratoWIPTotal.Init();
        IsHandled := false;
        OnCreateContratoWIPTotalOnBeforeLoopContratoTask(ContratoTask, ContratoWIPTotal, IsHandled);
        if not IsHandled then
            if ContratoTask.Find('-') then
                repeat
                    if ContratoTask."Contrato Task Type" = ContratoTask."Contrato Task Type"::Posting then begin
                        ContratoTask.CalcFields(
                        "Schedule (Total Cost)",
                        "Schedule (Total Price)",
                        "Usage (Total Cost)",
                        "Usage (Total Price)",
                        "Contract (Total Cost)",
                        "Contract (Total Price)",
                        "Contract (Invoiced Price)",
                        "Contract (Invoiced Cost)");

                        ContratoWIPTotal."Schedule (Total Cost)" += ContratoTask."Schedule (Total Cost)";
                        ContratoWIPTotal."Schedule (Total Price)" += ContratoTask."Schedule (Total Price)";
                        ContratoWIPTotal."Usage (Total Cost)" += ContratoTask."Usage (Total Cost)";
                        ContratoWIPTotal."Usage (Total Price)" += ContratoTask."Usage (Total Price)";
                        ContratoWIPTotal."Contract (Total Cost)" += ContratoTask."Contract (Total Cost)";
                        ContratoWIPTotal."Contract (Total Price)" += ContratoTask."Contract (Total Price)";
                        ContratoWIPTotal."Contract (Invoiced Price)" += ContratoTask."Contract (Invoiced Price)";
                        ContratoWIPTotal."Contract (Invoiced Cost)" += ContratoTask."Contract (Invoiced Cost)";

                        OnCreateContratoWIPTotalOnAfterUpdateContratoWIPTotal(ContratoTask, ContratoWIPTotal);
                    end;
                until ContratoTask.Next() = 0;

        // Get values from the "WIP-Total"::Total Contrato Task, which always is the last entry in the range:
        ContratoWIPTotal."Contrato No." := ContratoTask."Contrato No.";
        ContratoWIPTotal."Contrato Task No." := ContratoTask."Contrato Task No.";
        ContratoWIPTotal."WIP Posting Date" := WIPPostingDate;
        ContratoWIPTotal."WIP Posting Date Filter" :=
          CopyStr(ContratoTask.GetFilter("Posting Date Filter"), 1, MaxStrLen(ContratoWIPTotal."WIP Posting Date Filter"));
        ContratoWIPTotal."WIP Planning Date Filter" :=
          CopyStr(ContratoTask.GetFilter("Planning Date Filter"), 1, MaxStrLen(ContratoWIPTotal."WIP Planning Date Filter"));
        ContratoWIPTotal."WIP Method" := ContratoTask."WIP Method";
        ContratoWIPTotal.Insert();
    end;

    local procedure CalcWIP(var ContratoTask: Record "Contrato Task"; ContratoWIPTotal: Record "Contrato WIP Total")
    var
        ContratoWIPMethod: Record "Contrato WIP Method";
    begin
        OnBeforeCalcWIP(ContratoTask, ContratoWIPTotal, ContratoComplete, RecognizedAllocationPercentage, ContratoWIPTotalChanged);

        if ContratoComplete then begin
            ContratoTask."Recognized Sales Amount" := ContratoTask."Contract (Invoiced Price)";
            ContratoTask."Recognized Costs Amount" := ContratoTask."Usage (Total Cost)";
            OnCaclWIPOnAfterRecognizedAmounts(ContratoTask);
            exit;
        end;

        ContratoWIPMethod.Get(ContratoWIPTotal."WIP Method");
        CalcRecognizedCosts(ContratoTask, ContratoWIPTotal, ContratoWIPMethod);
        CalcRecognizedSales(ContratoTask, ContratoWIPTotal, ContratoWIPMethod);
        OnAfterCalcWIP(ContratoTask, ContratoWIPTotal, ContratoComplete, RecognizedAllocationPercentage, ContratoWIPTotalChanged);
    end;

    local procedure CalcRecognizedCosts(var ContratoTask: Record "Contrato Task"; ContratoWIPTotal: Record "Contrato WIP Total"; ContratoWIPMethod: Record "Contrato WIP Method")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalcRecognizedCosts(ContratoTask, ContratoWIPTotal, ContratoWIPMethod, IsHandled);
        if IsHandled then
            exit;

        case ContratoWIPMethod."Recognized Costs" of
            ContratoWIPMethod."Recognized Costs"::"Cost of Sales":
                CalcCostOfSales(ContratoTask, ContratoWIPTotal);
            ContratoWIPMethod."Recognized Costs"::"Cost Value":
                CalcCostValue(ContratoTask, ContratoWIPTotal);
            ContratoWIPMethod."Recognized Costs"::"Contract (Invoiced Cost)":
                CalcContractInvoicedCost(ContratoTask);
            ContratoWIPMethod."Recognized Costs"::"Usage (Total Cost)":
                CalcUsageTotalCostCosts(ContratoTask);
        end;
    end;

    local procedure CalcRecognizedSales(var ContratoTask: Record "Contrato Task"; ContratoWIPTotal: Record "Contrato WIP Total"; ContratoWIPMethod: Record "Contrato WIP Method")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalcRecognizedSales(ContratoTask, ContratoWIPTotal, ContratoWIPMethod, IsHandled);
        if IsHandled then
            exit;

        case ContratoWIPMethod."Recognized Sales" of
            ContratoWIPMethod."Recognized Sales"::"Contract (Invoiced Price)":
                CalcContractInvoicedPrice(ContratoTask);
            ContratoWIPMethod."Recognized Sales"::"Usage (Total Cost)":
                CalcUsageTotalCostSales(ContratoTask);
            ContratoWIPMethod."Recognized Sales"::"Usage (Total Price)":
                CalcUsageTotalPrice(ContratoTask);
            ContratoWIPMethod."Recognized Sales"::"Percentage of Completion":
                CalcPercentageofCompletion(ContratoTask, ContratoWIPTotal);
            ContratoWIPMethod."Recognized Sales"::"Sales Value":
                CalcSalesValue(ContratoTask, ContratoWIPTotal);
        end;
    end;

    local procedure CalcCostOfSales(var ContratoTask: Record "Contrato Task"; ContratoWIPTotal: Record "Contrato WIP Total")
    begin
        if ContratoWIPTotal."Contract (Total Price)" = 0 then
            exit;

        if ContratoWIPTotalChanged then begin
            WIPAmount := ContratoWIPTotal."Usage (Total Cost)" -
              ((ContratoWIPTotal."Contract (Invoiced Price)" / ContratoWIPTotal."Contract (Total Price)") *
               ContratoWIPTotal."Schedule (Total Cost)");
            if ContratoWIPTotal."Usage (Total Cost)" <> 0 then
                RecognizedAllocationPercentage := WIPAmount / ContratoWIPTotal."Usage (Total Cost)";
        end;

        if RecognizedAllocationPercentage <> 0 then
            WIPAmount := Round(ContratoTask."Usage (Total Cost)" * RecognizedAllocationPercentage);
        ContratoTask."Recognized Costs Amount" := ContratoTask."Usage (Total Cost)" - WIPAmount;
    end;

    local procedure CalcCostValue(var ContratoTask: Record "Contrato Task"; ContratoWIPTotal: Record "Contrato WIP Total")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalcCostValue(ContratoTask, ContratoWIPTotal, WIPAmount, RecognizedAllocationPercentage, ContratoWIPTotalChanged, IsHandled);
        if IsHandled then
            exit;

        if ContratoWIPTotal."Schedule (Total Price)" = 0 then
            exit;

        if ContratoWIPTotalChanged then begin
            WIPAmount :=
              (ContratoWIPTotal."Usage (Total Cost)" *
               ContratoWIPTotal."Contract (Total Price)" /
               ContratoWIPTotal."Schedule (Total Price)") -
              ContratoWIPTotal."Schedule (Total Cost)" *
              ContratoWIPTotal."Contract (Invoiced Price)" /
              ContratoWIPTotal."Schedule (Total Price)";
            if ContratoWIPTotal."Usage (Total Cost)" <> 0 then
                RecognizedAllocationPercentage := WIPAmount / ContratoWIPTotal."Usage (Total Cost)";
        end;

        if RecognizedAllocationPercentage <> 0 then
            WIPAmount := Round(ContratoTask."Usage (Total Cost)" * RecognizedAllocationPercentage);
        ContratoTask."Recognized Costs Amount" := ContratoTask."Usage (Total Cost)" - WIPAmount;
    end;

    local procedure CalcContractInvoicedCost(var ContratoTask: Record "Contrato Task")
    begin
        ContratoTask."Recognized Costs Amount" := ContratoTask."Contract (Invoiced Cost)";
    end;

    local procedure CalcUsageTotalCostCosts(var ContratoTask: Record "Contrato Task")
    begin
        ContratoTask."Recognized Costs Amount" := ContratoTask."Usage (Total Cost)";
        OnAfterCalcUsageTotalCostCosts(ContratoTask);
    end;

    local procedure CalcContractInvoicedPrice(var ContratoTask: Record "Contrato Task")
    begin
        ContratoTask."Recognized Sales Amount" := ContratoTask."Contract (Invoiced Price)";
    end;

    local procedure CalcUsageTotalCostSales(var ContratoTask: Record "Contrato Task")
    begin
        ContratoTask."Recognized Sales Amount" := ContratoTask."Usage (Total Cost)";
    end;

    local procedure CalcUsageTotalPrice(var ContratoTask: Record "Contrato Task")
    begin
        ContratoTask."Recognized Sales Amount" := ContratoTask."Usage (Total Price)";
    end;

    local procedure CalcPercentageofCompletion(var ContratoTask: Record "Contrato Task"; ContratoWIPTotal: Record "Contrato WIP Total")
    var
        IsHandled: Boolean;
    begin
        OnBeforeCalcPercentageOfCompletion(
          ContratoTask, ContratoWIPTotal, ContratoWIPTotalChanged, WIPAmount, RecognizedAllocationPercentage, IsHandled);
        if IsHandled then
            exit;

        if ContratoWIPTotal."Schedule (Total Cost)" = 0 then
            exit;

        if ContratoWIPTotalChanged then begin
            if ContratoWIPTotal."Usage (Total Cost)" <= ContratoWIPTotal."Schedule (Total Cost)" then
                WIPAmount :=
                  (ContratoWIPTotal."Usage (Total Cost)" / ContratoWIPTotal."Schedule (Total Cost)") *
                  ContratoWIPTotal."Contract (Total Price)"
            else
                WIPAmount := ContratoWIPTotal."Contract (Total Price)";
            if ContratoWIPTotal."Contract (Total Price)" <> 0 then
                RecognizedAllocationPercentage := WIPAmount / ContratoWIPTotal."Contract (Total Price)";
        end;

        if RecognizedAllocationPercentage <> 0 then
            WIPAmount := Round(ContratoTask."Contract (Total Price)" * RecognizedAllocationPercentage);
        ContratoTask."Recognized Sales Amount" := WIPAmount;
    end;

    local procedure CalcSalesValue(var ContratoTask: Record "Contrato Task"; ContratoWIPTotal: Record "Contrato WIP Total")
    begin
        if ContratoWIPTotal."Schedule (Total Price)" = 0 then
            exit;

        if ContratoWIPTotalChanged then begin
            WIPAmount :=
              (ContratoWIPTotal."Usage (Total Price)" *
               ContratoWIPTotal."Contract (Total Price)" /
               ContratoWIPTotal."Schedule (Total Price)") -
              ContratoWIPTotal."Contract (Invoiced Price)";
            if ContratoWIPTotal."Usage (Total Price)" <> 0 then
                RecognizedAllocationPercentage := WIPAmount / ContratoWIPTotal."Usage (Total Price)";
        end;

        if RecognizedAllocationPercentage <> 0 then
            WIPAmount := Round(ContratoTask."Usage (Total Price)" * RecognizedAllocationPercentage);
        ContratoTask."Recognized Sales Amount" := (ContratoTask."Contract (Invoiced Price)" + WIPAmount);
    end;

    local procedure CalcCostInvoicePercentage(var ContratoWIPTotal: Record "Contrato WIP Total")
    begin
        if ContratoWIPTotal."Schedule (Total Cost)" <> 0 then
            ContratoWIPTotal."Cost Completion %" := Round(100 * ContratoWIPTotal."Usage (Total Cost)" / ContratoWIPTotal."Schedule (Total Cost)", 0.00001)
        else
            ContratoWIPTotal."Cost Completion %" := 0;
        if ContratoWIPTotal."Contract (Total Price)" <> 0 then
            ContratoWIPTotal."Invoiced %" := Round(100 * ContratoWIPTotal."Contract (Invoiced Price)" / ContratoWIPTotal."Contract (Total Price)", 0.00001)
        else
            ContratoWIPTotal."Invoiced %" := 0;
    end;

    local procedure CreateTempContratoWIPBuffers(var ContratoTask: Record "Contrato Task"; var ContratoWIPTotal: Record "Contrato WIP Total")
    var
        Contrato: Record Contrato;
        ContratoWIPMethod: Record "Contrato WIP Method";
    begin
        Contrato.Get(ContratoTask."Contrato No.");
        ContratoWIPMethod.Get(ContratoWIPTotal."WIP Method");
        if not ContratoComplete then begin
            if ContratoTask."Recognized Costs Amount" <> 0 then begin
                CreateWIPBufferEntryFromTask(ContratoTask, ContratoWIPTotal, Enum::"Contrato WIP Buffer Type"::"Recognized Costs", false);
                if Contrato."WIP Posting Method" = Contrato."WIP Posting Method"::"Per Contrato" then
                    CreateWIPBufferEntryFromTask(ContratoTask, ContratoWIPTotal, Enum::"Contrato WIP Buffer Type"::"Applied Costs", false)
                else
                    FindContratoLedgerEntriesByContratoTask(ContratoTask, ContratoWIPTotal, Enum::"Contrato WIP Buffer Type"::"Applied Costs");
            end;
            if ContratoTask."Recognized Sales Amount" <> 0 then begin
                CreateWIPBufferEntryFromTask(ContratoTask, ContratoWIPTotal, Enum::"Contrato WIP Buffer Type"::"Recognized Sales", false);
                if (Contrato."WIP Posting Method" = Contrato."WIP Posting Method"::"Per Contrato") or
                    (ContratoWIPMethod."Recognized Sales" = ContratoWIPMethod."Recognized Sales"::"Percentage of Completion")
                then
                    CreateWIPBufferEntryFromTask(
                        ContratoTask, ContratoWIPTotal, Enum::"Contrato WIP Buffer Type"::"Applied Sales",
                        ((ContratoTask."Contract (Invoiced Price)" > ContratoTask."Recognized Sales Amount") and
                        (ContratoWIPMethod."Recognized Sales" = ContratoWIPMethod."Recognized Sales"::"Percentage of Completion")))
                else
                    FindContratoLedgerEntriesByContratoTask(ContratoTask, ContratoWIPTotal, Enum::"Contrato WIP Buffer Type"::"Applied Sales");
                if ContratoTask."Recognized Sales Amount" > ContratoTask."Contract (Invoiced Price)" then
                    CreateWIPBufferEntryFromTask(ContratoTask, ContratoWIPTotal, Enum::"Contrato WIP Buffer Type"::"Accrued Sales", false);
            end;
            if (ContratoTask."Recognized Costs Amount" = 0) and (ContratoTask."Usage (Total Cost)" <> 0) then
                if Contrato."WIP Posting Method" = Contrato."WIP Posting Method"::"Per Contrato" then
                    CreateWIPBufferEntryFromTask(ContratoTask, ContratoWIPTotal, Enum::"Contrato WIP Buffer Type"::"Applied Costs", false)
                else
                    FindContratoLedgerEntriesByContratoTask(ContratoTask, ContratoWIPTotal, Enum::"Contrato WIP Buffer Type"::"Applied Costs");
            if (ContratoTask."Recognized Sales Amount" = 0) and (ContratoTask."Contract (Invoiced Price)" <> 0) then
                if Contrato."WIP Posting Method" = Contrato."WIP Posting Method"::"Per Contrato" then
                    CreateWIPBufferEntryFromTask(ContratoTask, ContratoWIPTotal, Enum::"Contrato WIP Buffer Type"::"Applied Sales", false)
                else
                    FindContratoLedgerEntriesByContratoTask(ContratoTask, ContratoWIPTotal, Enum::"Contrato WIP Buffer Type"::"Applied Sales");
        end else begin
            if Contrato."WIP Posting Method" = Contrato."WIP Posting Method"::"Per Contrato Ledger Entry" then begin
                FindContratoLedgerEntriesByContratoTask(ContratoTask, ContratoWIPTotal, Enum::"Contrato WIP Buffer Type"::"Applied Costs");
                FindContratoLedgerEntriesByContratoTask(ContratoTask, ContratoWIPTotal, Enum::"Contrato WIP Buffer Type"::"Applied Sales");
            end;

            if ContratoTask."Recognized Costs Amount" <> 0 then
                CreateWIPBufferEntryFromTask(ContratoTask, ContratoWIPTotal, Enum::"Contrato WIP Buffer Type"::"Recognized Costs", false);
            if ContratoTask."Recognized Sales Amount" <> 0 then
                CreateWIPBufferEntryFromTask(ContratoTask, ContratoWIPTotal, Enum::"Contrato WIP Buffer Type"::"Recognized Sales", false);
        end;
    end;

    procedure CreateWIPBufferEntryFromTask(var ContratoTask: Record "Contrato Task"; var ContratoWIPTotal: Record "Contrato WIP Total"; ContratoWIPBufferType: Enum "Contrato WIP Buffer Type"; AppliedAccrued: Boolean)
    begin
        InitWIPBufferEntryFromTask(
          ContratoTask, ContratoWIPTotal, ContratoWIPBufferType, GetWIPEntryAmount(ContratoWIPBufferType, ContratoTask, ContratoWIPTotal."WIP Method", AppliedAccrued));
        UpdateWIPBufferEntryFromTask(ContratoTask, ContratoWIPTotal);
    end;

    local procedure InitWIPBufferEntryFromTask(var ContratoTask: Record "Contrato Task"; var ContratoWIPTotal: Record "Contrato WIP Total"; ContratoWIPBufferType: Enum "Contrato WIP Buffer Type"; WIPEntryAmount: Decimal)
    var
        ContratoTaskDimension: Record "Contrato Task Dimension";
        TempDimensionBuffer: Record "Dimension Buffer" temporary;
        Contrato: Record Contrato;
        ContratoPostingGroup: Record "Contrato Posting Group";
        ContratoWIPMethod: Record "Contrato WIP Method";
    begin
        Clear(TempContratoWIPBuffer);
        TempDimensionBuffer.Reset();
        TempDimensionBuffer.DeleteAll();

        ContratoTaskDimension.SetRange("Contrato No.", ContratoTask."Contrato No.");
        ContratoTaskDimension.SetRange("Contrato Task No.", ContratoTask."Contrato Task No.");
        if ContratoTaskDimension.FindSet() then
            repeat
                TempDimensionBuffer."Dimension Code" := ContratoTaskDimension."Dimension Code";
                TempDimensionBuffer."Dimension Value Code" := ContratoTaskDimension."Dimension Value Code";
                TempDimensionBuffer.Insert();
            until ContratoTaskDimension.Next() = 0;
        if not DimMgt.CheckDimBuffer(TempDimensionBuffer) then
            Error(DimMgt.GetDimCombErr());
        OnInitWIPBufferEntryFromTaskOnBeforeSetDimCombinationID(TempDimensionBuffer, ContratoTask);
        TempContratoWIPBuffer[1]."Dim Combination ID" := DimMgt.CreateDimSetIDFromDimBuf(TempDimensionBuffer);

        Contrato.Get(ContratoTask."Contrato No.");
        if ContratoTask."Contrato Posting Group" = '' then begin
            Contrato.TestField("Contrato Posting Group");
            ContratoTask."Contrato Posting Group" := Contrato."Contrato Posting Group";
        end;
        ContratoPostingGroup.Get(ContratoTask."Contrato Posting Group");
        ContratoWIPMethod.Get(ContratoWIPTotal."WIP Method");

        case ContratoWIPBufferType of
            Enum::"Contrato WIP Buffer Type"::"Applied Costs":
                begin
                    TempContratoWIPBuffer[1].Type := TempContratoWIPBuffer[1].Type::"Applied Costs";
                    TempContratoWIPBuffer[1]."G/L Account No." := ContratoPostingGroup.GetContratoCostsAppliedAccount();
                    TempContratoWIPBuffer[1]."Bal. G/L Account No." := ContratoPostingGroup.GetWIPCostsAccount();
                end;
            Enum::"Contrato WIP Buffer Type"::"Applied Sales":
                begin
                    TempContratoWIPBuffer[1].Type := TempContratoWIPBuffer[1].Type::"Applied Sales";
                    TempContratoWIPBuffer[1]."G/L Account No." := ContratoPostingGroup.GetContratoSalesAppliedAccount();
                    TempContratoWIPBuffer[1]."Bal. G/L Account No." := ContratoPostingGroup.GetWIPInvoicedSalesAccount();
                end;
            Enum::"Contrato WIP Buffer Type"::"Recognized Costs":
                begin
                    TempContratoWIPBuffer[1].Type := TempContratoWIPBuffer[1].Type::"Recognized Costs";
                    TempContratoWIPBuffer[1]."G/L Account No." := ContratoPostingGroup.GetRecognizedCostsAccount();
                    TempContratoWIPBuffer[1]."Bal. G/L Account No." := GetRecognizedCostsBalGLAccountNo(Contrato, ContratoPostingGroup);
                    TempContratoWIPBuffer[1]."Contrato Complete" := ContratoComplete;
                end;
            Enum::"Contrato WIP Buffer Type"::"Recognized Sales":
                begin
                    TempContratoWIPBuffer[1].Type := TempContratoWIPBuffer[1].Type::"Recognized Sales";
                    TempContratoWIPBuffer[1]."G/L Account No." := ContratoPostingGroup.GetRecognizedSalesAccount();
                    TempContratoWIPBuffer[1]."Bal. G/L Account No." := GetRecognizedSalesBalGLAccountNo(Contrato, ContratoPostingGroup, ContratoWIPMethod);
                    TempContratoWIPBuffer[1]."Contrato Complete" := ContratoComplete;
                end;
            Enum::"Contrato WIP Buffer Type"::"Accrued Costs":
                begin
                    TempContratoWIPBuffer[1].Type := TempContratoWIPBuffer[1].Type::"Accrued Costs";
                    TempContratoWIPBuffer[1]."G/L Account No." := ContratoPostingGroup.GetContratoCostsAdjustmentAccount();
                    TempContratoWIPBuffer[1]."Bal. G/L Account No." := ContratoPostingGroup.GetWIPAccruedCostsAccount();
                end;
            Enum::"Contrato WIP Buffer Type"::"Accrued Sales":
                begin
                    TempContratoWIPBuffer[1].Type := TempContratoWIPBuffer[1].Type::"Accrued Sales";
                    TempContratoWIPBuffer[1]."G/L Account No." := ContratoPostingGroup.GetContratoSalesAdjustmentAccount();
                    TempContratoWIPBuffer[1]."Bal. G/L Account No." := ContratoPostingGroup.GetWIPAccruedSalesAccount();
                end;
        end;
        TempContratoWIPBuffer[1]."WIP Entry Amount" := WIPEntryAmount;
    end;

    local procedure UpdateWIPBufferEntryFromTask(var ContratoTask: Record "Contrato Task"; var ContratoWIPTotal: Record "Contrato WIP Total")
    begin
        if TempContratoWIPBuffer[1]."WIP Entry Amount" <> 0 then begin
            TempContratoWIPBuffer[1].Reverse := true;
            TransferContratoTaskToTempContratoWIPBuf(ContratoTask, ContratoWIPTotal);
            UpdateTempContratoWIPBufferEntry();
        end;
    end;

    procedure FindContratoLedgerEntriesByContratoTask(var ContratoTask: Record "Contrato Task"; var ContratoWIPTotal: Record "Contrato WIP Total"; ContratoWIPBufferType: Enum "Contrato WIP Buffer Type")
    var
        ContratoLedgerEntry: Record "Contrato Ledger Entry";
        ContratoWIPMethod: Record "Contrato WIP Method";
    begin
        ContratoLedgerEntry.SetRange("Contrato No.", ContratoTask."Contrato No.");
        ContratoLedgerEntry.SetRange("Contrato Task No.", ContratoTask."Contrato Task No.");
        ContratoLedgerEntry.SetFilter("Posting Date", ContratoTask.GetFilter("Posting Date Filter"));
        if ContratoWIPBufferType = Enum::"Contrato WIP Buffer Type"::"Applied Costs" then
            ContratoLedgerEntry.SetRange("Entry Type", ContratoLedgerEntry."Entry Type"::Usage);
        if ContratoWIPBufferType = Enum::"Contrato WIP Buffer Type"::"Applied Sales" then begin
            ContratoLedgerEntry.SetRange("Entry Type", ContratoLedgerEntry."Entry Type"::Sale);
            if ContratoWIPMethod.Get(ContratoWIPTotal."WIP Method") then
                if ContratoWIPMethod."Recognized Sales" = ContratoWIPMethod."Recognized Sales"::"Usage (Total Price)" then
                    if ContratoTask."Contract (Invoiced Price)" < ContratoTask."Recognized Sales Amount" then
                        ContratoLedgerEntry.SetRange("Entry Type", ContratoLedgerEntry."Entry Type"::Usage);
        end;
        if ContratoLedgerEntry.FindSet() then
            repeat
                CreateWIPBufferEntryFromLedger(ContratoLedgerEntry, ContratoTask, ContratoWIPTotal, ContratoWIPBufferType)
            until ContratoLedgerEntry.Next() = 0;
    end;

    procedure CreateWIPBufferEntryFromLedger(var ContratoLedgerEntry: Record "Contrato Ledger Entry"; var ContratoTask: Record "Contrato Task"; var ContratoWIPTotal: Record "Contrato WIP Total"; ContratoWIPBufferType: Enum "Contrato WIP Buffer Type")
    var
        Contrato: Record Contrato;
        ContratoPostingGroup: Record "Contrato Posting Group";
    begin
        Clear(TempContratoWIPBuffer);
        TempContratoWIPBuffer[1]."Dim Combination ID" := ContratoLedgerEntry."Dimension Set ID";
        TempContratoWIPBuffer[1]."Contrato Complete" := ContratoComplete;
        OnBeforeCreateWIPBufferEntryFromLedgerOnBeforeAssignPostingGroup(TempContratoWIPBuffer[1], ContratoLedgerEntry, ContratoComplete);
        if ContratoTask."Contrato Posting Group" = '' then begin
            Contrato.Get(ContratoTask."Contrato No.");
            Contrato.TestField("Contrato Posting Group");
            ContratoTask."Contrato Posting Group" := Contrato."Contrato Posting Group";
        end;
        ContratoPostingGroup.Get(ContratoTask."Contrato Posting Group");

        case ContratoWIPBufferType of
            Enum::"Contrato WIP Buffer Type"::"Applied Costs":
                begin
                    TempContratoWIPBuffer[1].Type := TempContratoWIPBuffer[1].Type::"Applied Costs";
                    case ContratoLedgerEntry.Type of
                        ContratoLedgerEntry.Type::Item:
                            TempContratoWIPBuffer[1]."G/L Account No." := ContratoPostingGroup.GetItemCostsAppliedAccount();
                        ContratoLedgerEntry.Type::Resource:
                            TempContratoWIPBuffer[1]."G/L Account No." := ContratoPostingGroup.GetResourceCostsAppliedAccount();
                        ContratoLedgerEntry.Type::"G/L Account":
                            TempContratoWIPBuffer[1]."G/L Account No." := ContratoPostingGroup.GetGLCostsAppliedAccount();
                    end;
                    TempContratoWIPBuffer[1]."Bal. G/L Account No." := ContratoPostingGroup.GetWIPCostsAccount();
                    TempContratoWIPBuffer[1]."WIP Entry Amount" := -ContratoLedgerEntry."Total Cost (LCY)";
                    ContratoLedgerEntry."Amt. to Post to G/L" := ContratoLedgerEntry."Total Cost (LCY)" - ContratoLedgerEntry."Amt. Posted to G/L";
                end;
            Enum::"Contrato WIP Buffer Type"::"Applied Sales":
                begin
                    TempContratoWIPBuffer[1].Type := TempContratoWIPBuffer[1].Type::"Applied Sales";
                    TempContratoWIPBuffer[1]."G/L Account No." := ContratoPostingGroup.GetContratoSalesAppliedAccount();
                    TempContratoWIPBuffer[1]."Bal. G/L Account No." := ContratoPostingGroup.GetWIPInvoicedSalesAccount();
                    if ContratoLedgerEntry."Entry Type" = ContratoLedgerEntry."Entry Type"::Sale then
                        TempContratoWIPBuffer[1]."WIP Entry Amount" := -ContratoLedgerEntry."Line Amount (LCY)"
                    else
                        TempContratoWIPBuffer[1]."WIP Entry Amount" := ContratoLedgerEntry."Line Amount (LCY)";
                    ContratoLedgerEntry."Amt. to Post to G/L" := ContratoLedgerEntry."Line Amount (LCY)" - ContratoLedgerEntry."Amt. Posted to G/L";
                end;
        end;
        OnCreateWIPBufferEntryFromLedgerOnBeforeModifyContratoLedgerEntry(ContratoLedgerEntry, TempContratoWIPBuffer, ContratoWIPBufferType);
        ContratoLedgerEntry.Modify();

        if TempContratoWIPBuffer[1]."WIP Entry Amount" <> 0 then begin
            TempContratoWIPBuffer[1].Reverse := true;
            TransferContratoTaskToTempContratoWIPBuf(ContratoTask, ContratoWIPTotal);
            UpdateTempContratoWIPBufferEntry();
        end;
    end;

    local procedure TransferContratoTaskToTempContratoWIPBuf(ContratoTask: Record "Contrato Task"; ContratoWIPTotal: Record "Contrato WIP Total")
    var
        Contrato: Record Contrato;
    begin
        Contrato.Get(ContratoTask."Contrato No.");
        TempContratoWIPBuffer[1]."WIP Posting Method Used" := Contrato."WIP Posting Method";
        TempContratoWIPBuffer[1]."Contrato No." := ContratoTask."Contrato No.";
        TempContratoWIPBuffer[1]."Posting Group" := ContratoTask."Contrato Posting Group";
        TempContratoWIPBuffer[1]."WIP Method" := ContratoWIPTotal."WIP Method";
        TempContratoWIPBuffer[1]."Contrato WIP Total Entry No." := ContratoWIPTotal."Entry No.";
    end;

    local procedure UpdateTempContratoWIPBufferEntry()
    begin
        TempContratoWIPBuffer[2] := TempContratoWIPBuffer[1];
        if TempContratoWIPBuffer[2].Find() then begin
            TempContratoWIPBuffer[2]."WIP Entry Amount" += TempContratoWIPBuffer[1]."WIP Entry Amount";
            TempContratoWIPBuffer[2].Modify();
        end else
            TempContratoWIPBuffer[1].Insert();
    end;

    local procedure CreateWIPEntries(ContratoNo: Code[20])
    var
        ContratoWIPEntry: Record "Contrato WIP Entry";
        ContratoWIPMethod: Record "Contrato WIP Method";
        NextEntryNo: Integer;
        CreateEntry: Boolean;
    begin
        NextEntryNo := ContratoWIPEntry.GetLastEntryNo() + 1;

        GetGLSetup();
        if TempContratoWIPBuffer[1].Find('-') then
            repeat
                CreateEntry := true;

                ContratoWIPMethod.Get(TempContratoWIPBuffer[1]."WIP Method");
                if not ContratoWIPMethod."WIP Cost" and
                   ((TempContratoWIPBuffer[1].Type = TempContratoWIPBuffer[1].Type::"Recognized Costs") or
                    (TempContratoWIPBuffer[1].Type = TempContratoWIPBuffer[1].Type::"Applied Costs"))
                then
                    CreateEntry := false;

                if not ContratoWIPMethod."WIP Sales" and
                   ((TempContratoWIPBuffer[1].Type = TempContratoWIPBuffer[1].Type::"Recognized Sales") or
                    (TempContratoWIPBuffer[1].Type = TempContratoWIPBuffer[1].Type::"Applied Sales"))
                then
                    CreateEntry := false;

                if TempContratoWIPBuffer[1]."WIP Entry Amount" = 0 then
                    CreateEntry := false;

                if CreateEntry then begin
                    Clear(ContratoWIPEntry);
                    ContratoWIPEntry."Contrato No." := ContratoNo;
                    ContratoWIPEntry."WIP Posting Date" := WIPPostingDate;
                    ContratoWIPEntry."Document No." := DocNo;
                    ContratoWIPEntry.Type := TempContratoWIPBuffer[1].Type;
                    ContratoWIPEntry."Contrato Posting Group" := TempContratoWIPBuffer[1]."Posting Group";
                    ContratoWIPEntry."G/L Account No." := TempContratoWIPBuffer[1]."G/L Account No.";
                    ContratoWIPEntry."G/L Bal. Account No." := TempContratoWIPBuffer[1]."Bal. G/L Account No.";
                    ContratoWIPEntry."WIP Method Used" := TempContratoWIPBuffer[1]."WIP Method";
                    ContratoWIPEntry."Contrato Complete" := TempContratoWIPBuffer[1]."Contrato Complete";
                    ContratoWIPEntry."Contrato WIP Total Entry No." := TempContratoWIPBuffer[1]."Contrato WIP Total Entry No.";
                    ContratoWIPEntry."WIP Entry Amount" := Round(TempContratoWIPBuffer[1]."WIP Entry Amount");
                    ContratoWIPEntry.Reverse := TempContratoWIPBuffer[1].Reverse;
                    ContratoWIPEntry."WIP Posting Method Used" := TempContratoWIPBuffer[1]."WIP Posting Method Used";
                    ContratoWIPEntry."Entry No." := NextEntryNo;
                    ContratoWIPEntry."Dimension Set ID" := TempContratoWIPBuffer[1]."Dim Combination ID";
                    DimMgt.UpdateGlobalDimFromDimSetID(ContratoWIPEntry."Dimension Set ID", ContratoWIPEntry."Global Dimension 1 Code",
                      ContratoWIPEntry."Global Dimension 2 Code");
                    OnCreateWIPEntriesOnBeforeContratoWIPEntryInsert(ContratoWIPEntry);
                    ContratoWIPEntry.Insert(true);
                    NextEntryNo := NextEntryNo + 1;
                end;
            until TempContratoWIPBuffer[1].Next() = 0;
    end;

    procedure CalcGLWIP(ContratoNo: Code[20]; JustReverse: Boolean; DocNo: Code[20]; PostingDate: Date; NewPostDate: Boolean)
    var
        SourceCodeSetup: Record "Source Code Setup";
        GLEntry: Record "G/L Entry";
        Contrato: Record Contrato;
        ContratoWIPEntry: Record "Contrato WIP Entry";
        ContratoWIPGLEntry: Record "Contrato WIP G/L Entry";
        ContratoWIPTotal: Record "Contrato WIP Total";
        ContratoLedgerEntry: Record "Contrato Ledger Entry";
        ContratoTask: Record "Contrato Task";
        NextEntryNo: Integer;
        NextTransactionNo: Integer;
    begin
        ContratoWIPGLEntry.LockTable();
        ContratoWIPEntry.LockTable();
        Contrato.LockTable();

        ContratoWIPGLEntry.SetCurrentKey("Contrato No.", Reversed, "Contrato Complete");
        ContratoWIPGLEntry.SetRange("Contrato No.", ContratoNo);
        ContratoWIPGLEntry.SetRange("Contrato Complete", true);
        if not ContratoWIPGLEntry.IsEmpty() then
            exit;
        ContratoWIPGLEntry.Reset();

        Contrato.Get(ContratoNo);
        Contrato.TestBlocked();
        if NewPostDate then
            Contrato."WIP G/L Posting Date" := PostingDate;
        if JustReverse then
            Contrato."WIP G/L Posting Date" := 0D;
        Contrato.Modify();

        NextEntryNo := ContratoWIPGLEntry.GetLastEntryNo() + 1;

        ContratoWIPGLEntry.SetCurrentKey("WIP Transaction No.");
        if ContratoWIPGLEntry.FindLast() then
            NextTransactionNo := ContratoWIPGLEntry."WIP Transaction No." + 1
        else
            NextTransactionNo := 1;

        SourceCodeSetup.Get();

        // Reverse Entries
        ContratoWIPGLEntry.SetCurrentKey("Contrato No.", Reversed);
        ContratoWIPGLEntry.SetRange("Contrato No.", ContratoNo);
        ContratoWIPGLEntry.SetRange(Reverse, true);
        ContratoWIPGLEntry.SetRange(Reversed, false);
        if ContratoWIPGLEntry.Find('-') then
            repeat
                if ContratoWIPGLEntry."Posting Date" > PostingDate then
                    Error(Text004, ContratoWIPGLEntry."Contrato No.", ContratoWIPGLEntry."Posting Date");
            until ContratoWIPGLEntry.Next() = 0;
        if ContratoWIPGLEntry.Find('-') then
            repeat
                PostWIPGL(ContratoWIPGLEntry, true, DocNo, SourceCodeSetup."Job G/L WIP", PostingDate);
            until ContratoWIPGLEntry.Next() = 0;
        ContratoWIPGLEntry.ModifyAll("Reverse Date", PostingDate);
        ContratoWIPGLEntry.ModifyAll(Reversed, true);

        ContratoTask.SetRange("Contrato No.", Contrato."No.");
        if ContratoTask.FindSet() then
            repeat
                ContratoTask."Recognized Sales G/L Amount" := ContratoTask."Recognized Sales Amount";
                ContratoTask."Recognized Costs G/L Amount" := ContratoTask."Recognized Costs Amount";
                ContratoTask.Modify();
            until ContratoTask.Next() = 0;

        if JustReverse then
            exit;

        ContratoWIPEntry.SetRange("Contrato No.", ContratoNo);
        if ContratoWIPEntry.Find('-') then
            repeat
                Clear(ContratoWIPGLEntry);
                ContratoWIPGLEntry."Contrato No." := ContratoWIPEntry."Contrato No.";
                ContratoWIPGLEntry."Document No." := ContratoWIPEntry."Document No.";
                ContratoWIPGLEntry."G/L Account No." := ContratoWIPEntry."G/L Account No.";
                ContratoWIPGLEntry."G/L Bal. Account No." := ContratoWIPEntry."G/L Bal. Account No.";
                ContratoWIPGLEntry.Type := ContratoWIPEntry.Type;
                ContratoWIPGLEntry."WIP Posting Date" := ContratoWIPEntry."WIP Posting Date";
                if NewPostDate then
                    ContratoWIPGLEntry."Posting Date" := PostingDate
                else
                    ContratoWIPGLEntry."Posting Date" := ContratoWIPEntry."WIP Posting Date";
                ContratoWIPGLEntry."Contrato Posting Group" := ContratoWIPEntry."Contrato Posting Group";
                ContratoWIPGLEntry."WIP Method Used" := ContratoWIPEntry."WIP Method Used";
                if not NewPostDate then begin
                    Contrato."WIP G/L Posting Date" := ContratoWIPEntry."WIP Posting Date";
                    Contrato.Modify();
                end;
                ContratoWIPGLEntry.Reversed := false;
                ContratoWIPGLEntry."Contrato Complete" := ContratoWIPEntry."Contrato Complete";
                ContratoWIPGLEntry."WIP Transaction No." := NextTransactionNo;
                if ContratoWIPGLEntry.Type in [ContratoWIPGLEntry.Type::"Recognized Costs", ContratoWIPGLEntry.Type::"Recognized Sales"] then begin
                    if ContratoWIPGLEntry."Contrato Complete" then
                        ContratoWIPGLEntry.Description := StrSubstNo(Text003, ContratoNo)
                    else
                        ContratoWIPGLEntry.Description := StrSubstNo(Text002, ContratoNo);
                end else
                    ContratoWIPGLEntry.Description := StrSubstNo(Text001, ContratoNo);
                ContratoWIPGLEntry."WIP Entry Amount" := ContratoWIPEntry."WIP Entry Amount";
                ContratoWIPGLEntry.Reverse := ContratoWIPEntry.Reverse;
                ContratoWIPGLEntry."WIP Posting Method Used" := ContratoWIPEntry."WIP Posting Method Used";
                ContratoWIPGLEntry."Contrato WIP Total Entry No." := ContratoWIPEntry."Contrato WIP Total Entry No.";
                ContratoWIPGLEntry."Global Dimension 1 Code" := ContratoWIPEntry."Global Dimension 1 Code";
                ContratoWIPGLEntry."Global Dimension 2 Code" := ContratoWIPEntry."Global Dimension 2 Code";
                ContratoWIPGLEntry."Dimension Set ID" := ContratoWIPEntry."Dimension Set ID";
                ContratoWIPGLEntry."Entry No." := NextEntryNo;
                NextEntryNo := NextEntryNo + 1;
                PostWIPGL(ContratoWIPGLEntry,
                  false,
                  ContratoWIPGLEntry."Document No.",
                  SourceCodeSetup."Job G/L WIP",
                  ContratoWIPGLEntry."Posting Date");
                ContratoWIPGLEntry."G/L Entry No." := GLEntry.GetLastEntryNo();
                ContratoWIPGLEntry.Insert();
                ContratoWIPTotal.Get(ContratoWIPGLEntry."Contrato WIP Total Entry No.");
                ContratoWIPTotal."Posted to G/L" := true;
                ContratoWIPTotal.Modify();
            until ContratoWIPEntry.Next() = 0;

        ContratoLedgerEntry.SetRange("Contrato No.", Contrato."No.");
        ContratoLedgerEntry.SetFilter("Amt. to Post to G/L", '<>%1', 0);
        if ContratoLedgerEntry.FindSet() then
            repeat
                ContratoLedgerEntry."Amt. Posted to G/L" += ContratoLedgerEntry."Amt. to Post to G/L";
                ContratoLedgerEntry.Modify();
            until ContratoLedgerEntry.Next() = 0;

        DeleteWIP(Contrato);
    end;

    local procedure PostWIPGL(ContratoWIPGLEntry: Record "Contrato WIP G/L Entry"; Reversed: Boolean; JnlDocNo: Code[20]; SourceCode: Code[10]; JnlPostingDate: Date)
    var
        GLAmount: Decimal;
    begin
        CheckContratoGLAcc(ContratoWIPGLEntry."G/L Account No.");
        CheckContratoGLAcc(ContratoWIPGLEntry."G/L Bal. Account No.");
        GLAmount := ContratoWIPGLEntry."WIP Entry Amount";
        if Reversed then
            GLAmount := -GLAmount;

        InsertWIPGL(ContratoWIPGLEntry."G/L Account No.", ContratoWIPGLEntry."G/L Bal. Account No.", JnlPostingDate, JnlDocNo, SourceCode,
          GLAmount, ContratoWIPGLEntry.Description, ContratoWIPGLEntry."Contrato No.", ContratoWIPGLEntry."Dimension Set ID", Reversed, ContratoWIPGLEntry);
    end;

    local procedure InsertWIPGL(AccNo: Code[20]; BalAccNo: Code[20]; JnlPostingDate: Date; JnlDocNo: Code[20]; SourceCode: Code[10]; GLAmount: Decimal; JnlDescription: Text[100]; ContratoNo: Code[20]; ContratoWIPGLEntryDimSetID: Integer; Reversed: Boolean; ContratoWIPGLEntry: Record "Contrato WIP G/L Entry")
    var
        GenJnlLine: Record "Gen. Journal Line";
        GLAcc: Record "G/L Account";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInsertWIPGL(JnlPostingDate, JnlDocNo, SourceCode, GLAmount, ContratoWIPGLEntry, Reversed, IsHandled);
        if not IsHandled then begin
            GLAcc.Get(AccNo);
            GenJnlLine.Init();
            GenJnlLine."Posting Date" := JnlPostingDate;
            GenJnlLine."Account No." := AccNo;
            GenJnlLine."Bal. Account No." := BalAccNo;
            GenJnlLine."Tax Area Code" := GLAcc."Tax Area Code";
            GenJnlLine."Tax Liable" := GLAcc."Tax Liable";
            GenJnlLine."Tax Group Code" := GLAcc."Tax Group Code";
            GenJnlLine.Amount := GLAmount;
            GenJnlLine."Document No." := JnlDocNo;
            GenJnlLine."Source Code" := SourceCode;
            GenJnlLine.Description := JnlDescription;
            GenJnlLine."Job No." := ContratoNo;
            GenJnlLine."System-Created Entry" := true;
            GenJnlLine."Dimension Set ID" := ContratoWIPGLEntryDimSetID;
            GetGLSetup();
            if GLSetup."Journal Templ. Name Mandatory" then begin
                GenJnlLine."Journal Template Name" := GenJnlBatch."Journal Template Name";
                GenJnlLine."Journal Batch Name" := GenJnlBatch.Name;
            end;
            Clear(DimMgt);
            DimMgt.UpdateGlobalDimFromDimSetID(GenJnlLine."Dimension Set ID", GenJnlLine."Shortcut Dimension 1 Code",
              GenJnlLine."Shortcut Dimension 2 Code");

            OnInsertWIPGLOnBeforeGenJnPostLine(GenJnlLine, Reversed);
            GenJnPostLine.RunWithCheck(GenJnlLine);
        end;
    end;

    local procedure CheckContratoGLAcc(AccNo: Code[20])
    var
        GLAcc: Record "G/L Account";
        IsHandled: Boolean;
    begin
        OnBeforeCheckContratoGLAcc(AccNo, IsHandled);
        if IsHandled then
            exit;

        GLAcc.Get(AccNo);
        GLAcc.CheckGLAcc();
        GLAcc.TestField("Gen. Posting Type", GLAcc."Gen. Posting Type"::" ");
        GLAcc.TestField("Gen. Bus. Posting Group", '');
        GLAcc.TestField("Gen. Prod. Posting Group", '');
        GLAcc.TestField("VAT Bus. Posting Group", '');
        GLAcc.TestField("VAT Prod. Posting Group", '');
    end;

    local procedure GetGLSetup()
    begin
        if not HasGotGLSetup then begin
            GLSetup.Get();
            HasGotGLSetup := true;
        end;
    end;

    procedure ReOpenContrato(ContratoNo: Code[20])
    var
        Contrato: Record Contrato;
        ContratoWIPGLEntry: Record "Contrato WIP G/L Entry";
    begin
        Contrato.Get(ContratoNo);
        DeleteWIP(Contrato);
        ContratoWIPGLEntry.SetCurrentKey("Contrato No.", Reversed, "Contrato Complete");
        ContratoWIPGLEntry.SetRange("Contrato No.", ContratoNo);
        ContratoWIPGLEntry.ModifyAll("Contrato Complete", false);
    end;

    local procedure GetRecognizedCostsBalGLAccountNo(Contrato: Record Contrato; ContratoPostingGroup: Record "Contrato Posting Group"): Code[20]
    begin
        if not ContratoComplete or (Contrato."WIP Posting Method" = Contrato."WIP Posting Method"::"Per Contrato Ledger Entry") then
            exit(ContratoPostingGroup.GetWIPCostsAccount());

        exit(ContratoPostingGroup.GetContratoCostsAppliedAccount());
    end;

    local procedure GetRecognizedSalesBalGLAccountNo(Contrato: Record Contrato; ContratoPostingGroup: Record "Contrato Posting Group"; ContratoWIPMethod: Record "Contrato WIP Method"): Code[20]
    begin
        case true of
            not ContratoComplete and
          (ContratoWIPMethod."Recognized Sales" = ContratoWIPMethod."Recognized Sales"::"Percentage of Completion"):
                exit(ContratoPostingGroup.GetWIPAccruedSalesAccount());
            not ContratoComplete or (Contrato."WIP Posting Method" = Contrato."WIP Posting Method"::"Per Contrato Ledger Entry"):
                exit(ContratoPostingGroup.GetWIPInvoicedSalesAccount());
            else
                exit(ContratoPostingGroup.GetContratoSalesAppliedAccount());
        end;
    end;

    local procedure GetAppliedCostsWIPEntryAmount(ContratoTask: Record "Contrato Task"; ContratoWIPMethod: Record "Contrato WIP Method"; AppliedAccrued: Boolean): Decimal
    var
        IsHandled: Boolean;
        Result: Decimal;
    begin
        IsHandled := false;
        Result := 0;
        OnBeforeGetAppliedCostsWIPEntryAmount(ContratoTask, ContratoWIPMethod, AppliedAccrued, Result, IsHandled);
        if IsHandled then
            exit(Result);

        exit(GetAppliedCostsAmount(ContratoTask."Recognized Costs Amount", ContratoTask."Usage (Total Cost)", ContratoWIPMethod, AppliedAccrued));
    end;

    local procedure GetAppliedCostsAmount(RecognizedCostsAmount: Decimal; UsageTotalCost: Decimal; ContratoWIPMethod: Record "Contrato WIP Method"; AppliedAccrued: Boolean) AppliedCostsWIPEntryAmount: Decimal
    begin
        if AppliedAccrued then
            exit(UsageTotalCost - RecognizedCostsAmount);

        if IsAccruedCostsWIPMethod(ContratoWIPMethod) and (RecognizedCostsAmount <> 0) then begin
            AppliedCostsWIPEntryAmount := GetMAX(Abs(RecognizedCostsAmount), Abs(UsageTotalCost));
            if RecognizedCostsAmount > 0 then
                AppliedCostsWIPEntryAmount := -AppliedCostsWIPEntryAmount;
            exit(AppliedCostsWIPEntryAmount);
        end;

        exit(-UsageTotalCost);
    end;

    local procedure GetAppliedSalesWIPEntryAmount(ContratoTask: Record "Contrato Task"; ContratoWIPMethod: Record "Contrato WIP Method"; AppliedAccrued: Boolean) SalesAmount: Decimal
    begin
        if AppliedAccrued then begin
            SalesAmount := ContratoTask."Recognized Sales Amount" - ContratoTask."Contract (Invoiced Price)";
            if SalesAmount < 0 then
                exit(ContratoTask."Contract (Invoiced Price)");
            exit(SalesAmount);
        end;

        if IsAccruedSalesWIPMethod(ContratoWIPMethod) then
            exit(GetMAX(ContratoTask."Recognized Sales Amount", ContratoTask."Contract (Invoiced Price)"));

        exit(ContratoTask."Contract (Invoiced Price)");
    end;

    local procedure GetAccruedCostsAmount(ContratoWIPMethod: Record "Contrato WIP Method"; RecognizedCostsAmount: Decimal; UsageTotalCost: Decimal): Decimal
    begin
        if IsAccruedCostsWIPMethod(ContratoWIPMethod) then
            exit(RecognizedCostsAmount - UsageTotalCost);
        exit(0);
    end;

    local procedure GetAccruedSalesWIPEntryAmount(ContratoTask: Record "Contrato Task"; ContratoWIPMethod: Record "Contrato WIP Method"): Decimal
    begin
        if IsAccruedSalesWIPMethod(ContratoWIPMethod) then
            exit(-ContratoTask."Recognized Sales Amount" + ContratoTask."Contract (Invoiced Price)");
        exit(0);
    end;

    local procedure GetMAX(Value1: Decimal; Value2: Decimal): Decimal
    begin
        if Value1 > Value2 then
            exit(Value1);
        exit(Value2);
    end;

    local procedure GetWIPEntryAmount(ContratoWIPBufferType: Enum "Contrato WIP Buffer Type"; ContratoTask: Record "Contrato Task"; WIPMethodCode: Code[20]; AppliedAccrued: Boolean): Decimal
    var
        ContratoWIPMethod: Record "Contrato WIP Method";
        IsHandled: Boolean;
        Result: Decimal;
    begin
        ContratoWIPMethod.Get(WIPMethodCode);
        IsHandled := false;
        Result := 0;
        OnBeforeGetWIPEntryAmount(ContratoWIPBufferType, ContratoTask, ContratoWIPMethod, AppliedAccrued, Result, IsHandled);
        if IsHandled then
            exit(Result);
        case ContratoWIPBufferType of
            Enum::"Contrato WIP Buffer Type"::"Applied Costs":
                exit(GetAppliedCostsWIPEntryAmount(ContratoTask, ContratoWIPMethod, AppliedAccrued));
            Enum::"Contrato WIP Buffer Type"::"Applied Sales":
                exit(GetAppliedSalesWIPEntryAmount(ContratoTask, ContratoWIPMethod, AppliedAccrued));
            Enum::"Contrato WIP Buffer Type"::"Recognized Costs":
                exit(ContratoTask."Recognized Costs Amount");
            Enum::"Contrato WIP Buffer Type"::"Recognized Sales":
                exit(-ContratoTask."Recognized Sales Amount");
            Enum::"Contrato WIP Buffer Type"::"Accrued Sales":
                exit(GetAccruedSalesWIPEntryAmount(ContratoTask, ContratoWIPMethod));
        end;
    end;

    local procedure AssignWIPTotalAndMethodToRemainingContratoTask(var ContratoTask: Record "Contrato Task"; Contrato: Record Contrato)
    var
        RemainingContratoTask: Record "Contrato Task";
    begin
        RemainingContratoTask.Copy(ContratoTask);
        RemainingContratoTask.SetFilter("Contrato Task No.", '>%1', ContratoTask."Contrato Task No.");
        AssignWIPTotalAndMethodToContratoTask(RemainingContratoTask, Contrato);
    end;

    local procedure AssignWIPTotalAndMethodToContratoTask(var ContratoTask: Record "Contrato Task"; Contrato: Record Contrato)
    begin
        ContratoTask.SetRange("Contrato No.", Contrato."No.");
        ContratoTask.SetRange("WIP-Total", ContratoTask."WIP-Total"::Total);
        if not ContratoTask.FindFirst() then begin
            ContratoTask.SetFilter("WIP-Total", '<> %1', ContratoTask."WIP-Total"::Excluded);
            if ContratoTask.FindLast() then begin
                ContratoTask.Validate("WIP-Total", ContratoTask."WIP-Total"::Total);
                ContratoTask.Modify();
            end;
        end;

        ContratoTask.SetRange("WIP-Total", ContratoTask."WIP-Total"::Total);
        ContratoTask.SetRange("WIP Method", '');
        if ContratoTask.FindFirst() then
            ContratoTask.ModifyAll("WIP Method", Contrato."WIP Method");

        ContratoTask.SetRange("WIP-Total");
        ContratoTask.SetRange("WIP Method");
    end;

    local procedure IsAccruedCostsWIPMethod(ContratoWIPMethod: Record "Contrato WIP Method"): Boolean
    begin
        exit(
          ContratoWIPMethod."Recognized Costs" in
          [ContratoWIPMethod."Recognized Costs"::"Cost Value",
           ContratoWIPMethod."Recognized Costs"::"Cost of Sales",
           ContratoWIPMethod."Recognized Costs"::"Contract (Invoiced Cost)"]);
    end;

    local procedure IsAccruedSalesWIPMethod(ContratoWIPMethod: Record "Contrato WIP Method"): Boolean
    begin
        exit(
          ContratoWIPMethod."Recognized Sales" in
          [ContratoWIPMethod."Recognized Sales"::"Sales Value",
           ContratoWIPMethod."Recognized Sales"::"Usage (Total Price)"]);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Contrato Task", 'OnBeforeModifyEvent', '', false, false)]
    procedure VerifyContratoWIPEntryOnBeforeModify(var Rec: Record "Contrato Task"; var xRec: Record "Contrato Task"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        if ContratoTaskWIPRelatedFieldsAreModified(Rec) then
            VerifyContratoWIPEntryIsEmpty(Rec."Contrato No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Contrato Task", 'OnBeforeRenameEvent', '', false, false)]
    procedure VerifyContratoWIPEntryOnBeforeRename(var Rec: Record "Contrato Task"; var xRec: Record "Contrato Task"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        VerifyContratoWIPEntryIsEmpty(Rec."Contrato No.");
    end;

    local procedure ContratoTaskWIPRelatedFieldsAreModified(ContratoTask: Record "Contrato Task") Result: Boolean
    var
        OldContratoTask: Record "Contrato Task";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeContratoTaskWIPRelatedFieldsAreModified(ContratoTask, Result, IsHandled);
        if IsHandled then
            exit(Result);

        OldContratoTask.Get(ContratoTask."Contrato No.", ContratoTask."Contrato Task No.");
        exit(
          (OldContratoTask."Contrato Task Type" <> ContratoTask."Contrato Task Type") or
          (OldContratoTask."WIP-Total" <> ContratoTask."WIP-Total") or
          (OldContratoTask."Contrato Posting Group" <> ContratoTask."Contrato Posting Group") or
          (OldContratoTask."WIP Method" <> ContratoTask."WIP Method") or
          (OldContratoTask.Totaling <> ContratoTask.Totaling));
    end;

    local procedure VerifyContratoWIPEntryIsEmpty(ContratoNo: Code[20])
    var
        ContratoWIPEntry: Record "Contrato WIP Entry";
        ContratoTask: Record "Contrato Task";
    begin
        OnBeforeVerifyContratoWIPEntryIsEmpty(ContratoWIPEntry);
        ContratoWIPEntry.SetRange("Contrato No.", ContratoNo);
        if not ContratoWIPEntry.IsEmpty() then
            Error(CannotModifyAssociatedEntriesErr, ContratoTask.TableCaption());
    end;

    procedure SetGenJnlBatch(NewGenJnlBatch: Record "Gen. Journal Batch")
    begin
        GenJnlBatch := NewGenJnlBatch;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcUsageTotalCostCosts(var ContratoTask: Record "Contrato Task")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcWIP(var ContratoTask: Record "Contrato Task"; ContratoWIPTotal: Record "Contrato WIP Total"; ContratoComplete: Boolean; var RecognizedAllocationPercentage: Decimal; var ContratoWIPTotalChanged: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeActivateErrorMessageHandling(var Contrato: Record Contrato; var ErrorMessageMgt: Codeunit "Error Message Management"; var ErrorMessageHandler: Codeunit "Error Message Handler"; var ErrorContextElement: Codeunit "Error Context Element"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcPercentageOfCompletion(var ContratoTask: Record "Contrato Task"; ContratoWIPTotal: Record "Contrato WIP Total"; var ContratoWIPTotalChanged: Boolean; var WIPAmount: Decimal; var RecognizedAllocationPercentage: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcRecognizedCosts(var ContratoTask: Record "Contrato Task"; var ContratoWIPTotal: Record "Contrato WIP Total"; var ContratoWIPMethod: Record "Contrato WIP Method"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcRecognizedSales(var ContratoTask: Record "Contrato Task"; var ContratoWIPTotal: Record "Contrato WIP Total"; var ContratoWIPMethod: Record "Contrato WIP Method"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcCostValue(var ContratoTask: Record "Contrato Task"; ContratoWIPTotal: Record "Contrato WIP Total"; var WIPAmount: Decimal; var RecognizedAllocationPercentage: Decimal; var ContratoWIPTotalChanged: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeContratoTaskWIPRelatedFieldsAreModified(ContratoTask: Record "Contrato Task"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeVerifyContratoWIPEntryIsEmpty(var ContratoWIPEntry: Record "Contrato WIP Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateWIPEntriesOnBeforeContratoWIPEntryInsert(var ContratoWIPEntry: Record "Contrato WIP Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateContratoWIPTotalOnAfterUpdateContratoWIPTotal(var ContratoTask: Record "Contrato Task"; var ContratoWIPTotal: Record "Contrato WIP Total")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateContratoWIPTotal(var ContratoTask: Record "Contrato Task")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitWIPBufferEntryFromTaskOnBeforeSetDimCombinationID(var TempDimensionBuffer: Record "Dimension Buffer" temporary; ContratoTask: Record "Contrato Task")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertWIPGLOnBeforeGenJnPostLine(var GenJournalLine: Record "Gen. Journal Line"; Reversed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnContratoTaskCalcWIPOnAfterContratoWIPTotalModify(var Contrato: Record Contrato; var ContratoWIPTotal: Record "Contrato WIP Total")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnContratoCalcWIPOnBeforeContratoModify(var Contrato: Record Contrato; var ContratoComplete: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnContratoTaskCalcWIPOnBeforeContratoWIPTotalModify(var Contrato: Record Contrato; var ContratoWIPTotal: Record "Contrato WIP Total")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterContratoTaskCalcWIP(var Contrato: Record Contrato; FromContratoTask: Code[20]; ToContratoTask: Code[20]; var ContratoWIPTotal: Record "Contrato WIP Total")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcWIP(var ContratoTask: Record "Contrato Task"; ContratoWIPTotal: Record "Contrato WIP Total"; ContratoComplete: Boolean; var RecognizedAllocationPercentage: Decimal; var ContratoWIPTotalChanged: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnContratoTaskCalcWIPOnBeforeCreateTempContratoWIPBuffer(var ContratoTask: Record "Contrato Task"; var ContratoWIPTotal: Record "Contrato WIP Total"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnContratoTaskCalcWIPOnBeforeCalcWIP(var ContratoTask: Record "Contrato Task")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCaclWIPOnAfterRecognizedAmounts(var ContratoTask: Record "Contrato Task")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateWIPBufferEntryFromLedgerOnBeforeModifyContratoLedgerEntry(var ContratoLedgerEntry: Record "Contrato Ledger Entry"; var TempContratoWIPBuffer: array[2] of Record "Contrato WIP Buffer" temporary; ContratoWIPBufferType: Enum "Contrato WIP Buffer Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetAppliedCostsWIPEntryAmount(ContratoTask: Record "Contrato Task"; ContratoWIPMethod: Record "Contrato WIP Method"; AppliedAccrued: Boolean; var Result: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateWIPBufferEntryFromLedgerOnBeforeAssignPostingGroup(var TempContratoWIPBuffer: Record "Contrato WIP Buffer"; var ContratoLedgerEntry: Record "Contrato Ledger Entry"; ContratoComplete: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertWIPGL(JnlPostingDate: Date; JnlDocNo: Code[20]; SourceCode: Code[10]; GLAmount: Decimal; ContratoWIPGLEntry: Record "Contrato WIP G/L Entry"; Reversed: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnContratoTaskCalcWIPOnBeforeSumContratoTaskCosts(var ContratoTask: Record "Contrato Task"; var RecognizedCostAmount: Decimal; var UsageTotalCost: Decimal; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateContratoWIPTotalOnBeforeLoopContratoTask(var ContratoTask: Record "Contrato Task"; var ContratoWIPTotal: Record "Contrato WIP Total"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetWIPEntryAmount(ContratoWIPBufferType: Enum "Contrato WIP Buffer Type"; ContratoTask: Record "Contrato Task"; ContratoWIPMethod: Record "Contrato WIP Method"; AppliedAccrued: Boolean; var Result: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckContratoGLAcc(AccNo: Code[20]; var IsHandled: Boolean)
    begin
    end;
}

