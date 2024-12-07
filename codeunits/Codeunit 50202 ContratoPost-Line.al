codeunit 50202 "Contrato Post-Line"
{
    Permissions = TableData "Contrato Ledger Entry" = rm,
                  TableData "Contrato Planning Line" = rimd;

    trigger OnRun()
    begin
    end;

    var
        TempSalesLineJob: Record "Sales Line" temporary;
        TempPurchaseLineJob: Record "Purchase Line" temporary;
        TempJobJournalLine: Record "Contrato Journal Line" temporary;
        JobJnlPostLine: Codeunit "Contrato Jnl.-Post Line";
        JobTransferLine: Codeunit "Contrato Transfer Line";
        UOMMgt: Codeunit "Unit of Measure Management";
        Text000: Label 'has been changed (initial a %1: %2= %3, %4= %5)';
        Text003: Label 'You cannot change the sales line because it is linked to\';
        Text004: Label ' %1: %2= %3, %4= %5.';
        Text005: Label 'You must post more usage or credit the sale of %1 %2 in %3 %4 before you can post purchase credit memo %5 %6 = %7.';

    procedure InsertPlLineFromLedgEntry(var JobLedgEntry: Record "Contrato Ledger Entry")
    var
        JobPlanningLine: Record "Contrato Planning Line";
        IsHandled: Boolean;
    begin
        OnBeforeInsertPlLineFromLedgEntry(JobLedgEntry, IsHandled);
        if not IsHandled then begin
            if JobLedgEntry."Line Type" = JobLedgEntry."Line Type"::" " then
                exit;
            ClearAll();
            JobPlanningLine."Contrato No." := JobLedgEntry."Contrato No.";
            JobPlanningLine."Contrato Task No." := JobLedgEntry."Contrato Task No.";
            JobPlanningLine.SetRange("Contrato No.", JobPlanningLine."Contrato No.");
            JobPlanningLine.SetRange("Contrato Task No.", JobPlanningLine."Contrato Task No.");
            if JobPlanningLine.FindLast() then;
            JobPlanningLine."Line No." := JobPlanningLine."Line No." + 10000;
            JobPlanningLine.Init();
            JobPlanningLine.Reset();
            Clear(JobTransferLine);
            JobTransferLine.FromJobLedgEntryToPlanningLine(JobLedgEntry, JobPlanningLine);
            PostPlanningLine(JobPlanningLine);
        end;

        OnAfterInsertPlLineFromLedgEntry(JobLedgEntry, JobPlanningLine);
    end;

    procedure PostPlanningLine(var JobPlanningLine: Record "Contrato Planning Line")
    var
        Contrato: Record Contrato;
    begin
        OnBeforePostPlanningLine(JobPlanningLine);

        if JobPlanningLine."Line Type" = JobPlanningLine."Line Type"::"Both Budget and Billable" then begin
            Contrato.Get(JobPlanningLine."Contrato No.");
            if not Contrato."Allow Schedule/Contract Lines" or
               (JobPlanningLine.Type = JobPlanningLine.Type::"G/L Account")
            then begin
                JobPlanningLine.Validate("Line Type", JobPlanningLine."Line Type"::Budget);
                JobPlanningLine.Insert(true);
                InsertJobUsageLink(JobPlanningLine);
                JobPlanningLine.Validate("Qty. to Transfer to Journal", 0);
                JobPlanningLine.Modify(true);
                JobPlanningLine."Contrato Contract Entry No." := 0;
                JobPlanningLine."Line No." := JobPlanningLine."Line No." + 10000;
                JobPlanningLine.Validate("Line Type", JobPlanningLine."Line Type"::Billable);
            end;
        end;
        if (JobPlanningLine.Type = JobPlanningLine.Type::"G/L Account") and
           (JobPlanningLine."Line Type" = JobPlanningLine."Line Type"::Billable)
        then
            ChangeGLAccNo(JobPlanningLine);
        OnPostPlanningLineOnBeforeJobPlanningLineInsert(JobPlanningLine);
        JobPlanningLine.Insert(true);
        JobPlanningLine.Validate("Qty. to Transfer to Journal", 0);
        JobPlanningLine.Modify(true);
        if JobPlanningLine."Line Type" in
           [JobPlanningLine."Line Type"::Budget, JobPlanningLine."Line Type"::"Both Budget and Billable"]
        then
            InsertJobUsageLink(JobPlanningLine);
    end;

    local procedure InsertJobUsageLink(var JobPlanningLine: Record "Contrato Planning Line")
    var
        JobUsageLink: Record "Contrato Usage Link";
        JobLedgerEntry: Record "Contrato Ledger Entry";
    begin
        if not JobPlanningLine."Usage Link" then
            exit;
        JobLedgerEntry.Get(JobPlanningLine."Contrato Ledger Entry No.");
        if UsageLinkExist(JobLedgerEntry) then
            exit;
        JobUsageLink.Create(JobPlanningLine, JobLedgerEntry);

        JobPlanningLine.Use(
            UOMMgt.CalcQtyFromBase(
                JobPlanningLine."No.", JobPlanningLine."Variant Code", JobPlanningLine."Unit of Measure Code",
                JobLedgerEntry."Quantity (Base)", JobPlanningLine."Qty. per Unit of Measure"),
            JobLedgerEntry."Total Cost", JobLedgerEntry."Line Amount", JobLedgerEntry."Posting Date", JobLedgerEntry."Currency Factor");
    end;

    local procedure UsageLinkExist(JobLedgEntry: Record "Contrato Ledger Entry"): Boolean
    var
        JobUsageLink: Record "Contrato Usage Link";
    begin
        JobUsageLink.SetRange("Contrato No.", JobLedgEntry."Contrato No.");
        JobUsageLink.SetRange("Contrato Task No.", JobLedgEntry."Contrato Task No.");
        JobUsageLink.SetRange("Entry No.", JobLedgEntry."Entry No.");
        if not JobUsageLink.IsEmpty then
            exit(true);
    end;

    procedure PostInvoiceContractLine(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")
    var
        Contrato: Record Contrato;
        JobTask: Record "Contrato Task";
        JobPlanningLine: Record "Contrato Planning Line";
        JobPlanningLineInvoice: Record "Contrato Planning Line Invoice";
        DummyJobLedgEntryNo: Integer;
        JobLineChecked: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostInvoiceContractLine(SalesHeader, SalesLine, IsHandled);
        if IsHandled then
            exit;

        JobPlanningLine.SetCurrentKey("Contrato Contract Entry No.");
        JobPlanningLine.SetRange("Contrato Contract Entry No.", SalesLine."Job Contract Entry No.");
        OnPostInvoiceContractLineOnBeforeJobPlanningLineFindFirst(SalesHeader, SalesLine, JobPlanningLine);
        JobPlanningLine.FindFirst();
        Contrato.Get(JobPlanningLine."Contrato No.");

        CheckCurrency(Contrato, SalesHeader, JobPlanningLine);

        IsHandled := false;
        OnPostInvoiceContractLineOnBeforeCheckBillToCustomer(SalesHeader, SalesLine, JobPlanningLine, IsHandled);
        if not IsHandled then
            if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
                SalesHeader.TestField("Bill-to Customer No.", Contrato."Bill-to Customer No.")
            else begin
                JobTask.Get(JobPlanningLine."Contrato No.", JobPlanningLine."Contrato Task No.");
                SalesHeader.TestField("Bill-to Customer No.", JobTask."Bill-to Customer No.");
            end;

        OnPostInvoiceContractLineBeforeCheckJobLine(SalesHeader, SalesLine, JobPlanningLine, JobLineChecked);
        if not JobLineChecked then begin
            JobPlanningLine.CalcFields("Qty. Transferred to Invoice");
            if JobPlanningLine.Type <> JobPlanningLine.Type::Text then
                JobPlanningLine.TestField("Qty. Transferred to Invoice");
        end;

        ValidateRelationship(SalesHeader, SalesLine, JobPlanningLine);

        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Invoice:
                if JobPlanningLineInvoice.Get(JobPlanningLine."Contrato No.", JobPlanningLine."Contrato Task No.", JobPlanningLine."Line No.",
                     JobPlanningLineInvoice."Document Type"::Invoice, SalesHeader."No.", SalesLine."Line No.")
                then begin
                    JobPlanningLineInvoice.Delete(true);
                    JobPlanningLineInvoice."Document Type" := JobPlanningLineInvoice."Document Type"::"Posted Invoice";
                    JobPlanningLineInvoice."Document No." := SalesLine."Document No.";
                    JobPlanningLineInvoice.Insert(true);

                    JobPlanningLineInvoice."Invoiced Date" := SalesHeader."Posting Date";
                    JobPlanningLineInvoice."Invoiced Amount (LCY)" :=
                      CalcLineAmountLCY(JobPlanningLine, JobPlanningLineInvoice."Quantity Transferred");
                    JobPlanningLineInvoice."Invoiced Cost Amount (LCY)" :=
                      JobPlanningLineInvoice."Quantity Transferred" * JobPlanningLine."Unit Cost (LCY)";
                    JobPlanningLineInvoice.Modify();
                end;
            SalesHeader."Document Type"::"Credit Memo":
                if JobPlanningLineInvoice.Get(JobPlanningLine."Contrato No.", JobPlanningLine."Contrato Task No.", JobPlanningLine."Line No.",
                     JobPlanningLineInvoice."Document Type"::"Credit Memo", SalesHeader."No.", SalesLine."Line No.")
                then begin
                    JobPlanningLineInvoice.Delete(true);
                    JobPlanningLineInvoice."Document Type" := JobPlanningLineInvoice."Document Type"::"Posted Credit Memo";
                    JobPlanningLineInvoice."Document No." := SalesLine."Document No.";
                    JobPlanningLineInvoice.Insert(true);

                    JobPlanningLineInvoice."Invoiced Date" := SalesHeader."Posting Date";
                    JobPlanningLineInvoice."Invoiced Amount (LCY)" :=
                      CalcLineAmountLCY(JobPlanningLine, JobPlanningLineInvoice."Quantity Transferred");
                    JobPlanningLineInvoice."Invoiced Cost Amount (LCY)" :=
                      JobPlanningLineInvoice."Quantity Transferred" * JobPlanningLine."Unit Cost (LCY)";
                    JobPlanningLineInvoice.Modify();
                end;
        end;

        OnBeforeJobPlanningLineUpdateQtyToInvoice(SalesHeader, SalesLine, JobPlanningLine, JobPlanningLineInvoice, DummyJobLedgEntryNo);

        JobPlanningLine.UpdateQtyToInvoice();
        JobPlanningLine.Modify();

        OnAfterJobPlanningLineModify(JobPlanningLine);

        IsHandled := false;
        OnPostInvoiceContractLineOnBeforePostJobOnSalesLine(JobPlanningLine, JobPlanningLineInvoice, SalesHeader, SalesLine, IsHandled);
        if not IsHandled then
            if JobPlanningLine.Type <> JobPlanningLine.Type::Text then
                PostJobOnSalesLine(JobPlanningLine, SalesHeader, SalesLine, ContratoJournalLineEntryType::Sale);

        OnAfterPostInvoiceContractLine(SalesHeader, SalesLine);
    end;

    local procedure ValidateRelationship(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; JobPlanningLine: Record "Contrato Planning Line")
    var
        JobTask: Record "Contrato Task";
        Txt: Text[500];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeValidateRelationship(SalesHeader, SalesLine, JobPlanningLine, IsHandled);
        if IsHandled then
            exit;

        JobTask.Get(JobPlanningLine."Contrato No.", JobPlanningLine."Contrato Task No.");
        Txt := StrSubstNo(Text000,
            JobTask.TableCaption(), JobTask.FieldCaption("Contrato No."), JobTask."Contrato No.",
            JobTask.FieldCaption("Contrato Task No."), JobTask."Contrato Task No.");

        if JobPlanningLine.Type = JobPlanningLine.Type::Text then
            if SalesLine.Type <> SalesLine.Type::" " then
                SalesLine.FieldError(Type, Txt);
        if JobPlanningLine.Type = JobPlanningLine.Type::Resource then
            if SalesLine.Type <> SalesLine.Type::Resource then
                SalesLine.FieldError(Type, Txt);
        if JobPlanningLine.Type = JobPlanningLine.Type::Item then
            if SalesLine.Type <> SalesLine.Type::Item then
                SalesLine.FieldError(Type, Txt);
        if JobPlanningLine.Type = JobPlanningLine.Type::"G/L Account" then
            if SalesLine.Type <> SalesLine.Type::"G/L Account" then
                SalesLine.FieldError(Type, Txt);

        if SalesLine."No." <> JobPlanningLine."No." then
            SalesLine.FieldError("No.", Txt);
        if SalesLine."Location Code" <> JobPlanningLine."Location Code" then
            SalesLine.FieldError("Location Code", Txt);
        if SalesLine."Work Type Code" <> JobPlanningLine."Work Type Code" then
            SalesLine.FieldError("Work Type Code", Txt);
        if SalesLine."Unit of Measure Code" <> JobPlanningLine."Unit of Measure Code" then
            SalesLine.FieldError("Unit of Measure Code", Txt);
        if SalesLine."Variant Code" <> JobPlanningLine."Variant Code" then
            SalesLine.FieldError("Variant Code", Txt);
        if SalesLine."Gen. Prod. Posting Group" <> JobPlanningLine."Gen. Prod. Posting Group" then
            SalesLine.FieldError("Gen. Prod. Posting Group", Txt);

        IsHandled := false;
        OnValidateRelationshipOnBeforeCheckLineDiscount(SalesLine, JobPlanningLine, IsHandled);
        if not IsHandled then
            if SalesLine."Line Discount %" <> JobPlanningLine."Line Discount %" then
                SalesLine.FieldError("Line Discount %", Txt);
        if SalesLine."Unit Cost (LCY)" <> JobPlanningLine."Unit Cost (LCY)" then
            SalesLine.FieldError("Unit Cost (LCY)", Txt);
        if SalesLine.Type = SalesLine.Type::" " then
            if SalesLine."Line Amount" <> 0 then
                SalesLine.FieldError("Line Amount", Txt);
        if SalesHeader."Prices Including VAT" then
            if JobPlanningLine."VAT %" <> SalesLine."VAT %" then
                SalesLine.FieldError("VAT %", Txt);
    end;

    procedure PostJobOnSalesLine(JobPlanningLine: Record "Contrato Planning Line"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; EntryType: Enum ContratoJournalLineEntryType)
    var
        JobJnlLine: Record "Contrato Journal Line";
    begin
        JobTransferLine.FromPlanningSalesLineToJnlLine(JobPlanningLine, SalesHeader, SalesLine, JobJnlLine, EntryType);
        if SalesLine.Type = SalesLine.Type::"G/L Account" then begin
            TempSalesLineJob := SalesLine;
            TempSalesLineJob.Insert();
            InsertTempJobJournalLine(JobJnlLine, TempSalesLineJob."Line No.");
        end else
            PostSalesJobJournalLine(JobJnlLine);
    end;

    procedure CalcLineAmountLCY(JobPlanningLine: Record "Contrato Planning Line"; Qty: Decimal): Decimal
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        TotalPrice: Decimal;
        UnitPriceLCY: Decimal;
    begin
        if JobPlanningLine."Currency Code" <> '' then
            UnitPriceLCY :=
              CurrencyExchangeRate.ExchangeAmtFCYToLCY(
                JobPlanningLine."Currency Date", JobPlanningLine."Currency Code",
                JobPlanningLine."Unit Price", JobPlanningLine."Currency Factor")
        else
            UnitPriceLCY := JobPlanningLine."Unit Price";

        TotalPrice := Round(Qty * UnitPriceLCY, 0.01);
        exit(TotalPrice - Round(TotalPrice * JobPlanningLine."Line Discount %" / 100, 0.01));
    end;

    procedure PostGenJnlLine(GenJnlLine: Record "Gen. Journal Line"; GLEntry: Record "G/L Entry")
    var
        JobJnlLine: Record "Contrato Journal Line";
        Contrato: Record Contrato;
        JobTask: Record "Contrato Task";
        SourceCodeSetup: Record "Source Code Setup";
        JobTransferLine: Codeunit "Contrato Transfer Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostGenJnlLine(JobJnlLine, GenJnlLine, GLEntry, IsHandled, JobJnlPostLine);
        if IsHandled then
            exit;

        OnPostGenJnlLineOnBeforeGenJnlCheck(JobJnlLine, GenJnlLine, GLEntry, IsHandled);
        if not IsHandled then begin
            if GenJnlLine."System-Created Entry" then
                exit;
            if GenJnlLine."Job No." = '' then
                exit;
            SourceCodeSetup.Get();
            if GenJnlLine."Source Code" = SourceCodeSetup."Job G/L WIP" then
                exit;
            GenJnlLine.TestField("Job Task No.");
            GenJnlLine.TestField("Job Quantity");
            Contrato.LockTable();
            JobTask.LockTable();
            Contrato.Get(GenJnlLine."Job No.");
            GenJnlLine.TestField("Job Currency Code", Contrato."Currency Code");
            JobTask.Get(GenJnlLine."Job No.", GenJnlLine."Job Task No.");
            JobTask.TestField("Contrato Task Type", JobTask."Contrato Task Type"::Posting);
        end;
        JobTransferLine.FromGenJnlLineToJnlLine(GenJnlLine, JobJnlLine);
        OnPostGenJnlLineOnAfterTransferToJnlLine(JobJnlLine, GenJnlLine, JobJnlPostLine);

        JobJnlPostLine.SetGLEntryNo(GLEntry."Entry No.");
        JobJnlPostLine.RunWithCheck(JobJnlLine);
        JobJnlPostLine.SetGLEntryNo(0);
    end;

    procedure PostJobOnPurchaseLine(var PurchHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; PurchLine: Record "Purchase Line"; SourceCode: Code[10])
    var
        JobJnlLine: Record "Contrato Journal Line";
        Contrato: Record Contrato;
        JobTask: Record "Contrato Task";
        IsHandled: Boolean;
        ShouldSkipLine: Boolean;
    begin
        IsHandled := false;
        OnBeforePostJobOnPurchaseLine(
            PurchHeader, PurchInvHeader, PurchCrMemoHdr, PurchLine, JobJnlLine, IsHandled,
            TempPurchaseLineJob, TempJobJournalLine, SourceCode);
        if IsHandled then
            exit;

        ShouldSkipLine := (PurchLine.Type <> PurchLine.Type::Item) and (PurchLine.Type <> PurchLine.Type::"G/L Account");
        OnPostJobOnPurchaseLineOnAfterCalcShouldSkipLine(PurchLine, ShouldSkipLine);
        if ShouldSkipLine then
            exit;
        Clear(JobJnlLine);
        PurchLine.TestField("Job No.");
        PurchLine.TestField("Job Task No.");
        Contrato.LockTable();
        JobTask.LockTable();
        Contrato.Get(PurchLine."Job No.");
        PurchLine.TestField("Job Currency Code", Contrato."Currency Code");
        JobTask.Get(PurchLine."Job No.", PurchLine."Job Task No.");
        JobTransferLine.FromPurchaseLineToJnlLine(
          PurchHeader, PurchInvHeader, PurchCrMemoHdr, PurchLine, Sourcecode, JobJnlLine);
        OnPostJobOnPurchaseLineOnAfterJobTransferLineFromPurchaseLineToJnlLine(PurchHeader, PurchInvHeader, PurchCrMemoHdr, PurchLine, JobJnlLine);
        JobJnlLine."Contrato Posting Only" := true;

        if PurchLine.Type = PurchLine.Type::"G/L Account" then begin
            TempPurchaseLineJob := PurchLine;
            TempPurchaseLineJob.Insert();
            InsertTempJobJournalLine(JobJnlLine, TempPurchaseLineJob."Line No.");
        end else
            JobJnlPostLine.RunWithCheck(JobJnlLine);
    end;

    procedure TestSalesLine(var SalesLine: Record "Sales Line")
    var
        JT: Record "Contrato Task";
        JobPlanningLine: Record "Contrato Planning Line";
        Txt: Text[250];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestSalesLine(SalesLine, IsHandled);
        if IsHandled then
            exit;

        if SalesLine."Job Contract Entry No." = 0 then
            exit;
        JobPlanningLine.SetCurrentKey("Contrato Contract Entry No.");
        JobPlanningLine.SetRange("Contrato Contract Entry No.", SalesLine."Job Contract Entry No.");
        if JobPlanningLine.FindFirst() then begin
            JT.Get(JobPlanningLine."Contrato No.", JobPlanningLine."Contrato Task No.");
            Txt := Text003 + StrSubstNo(Text004,
                JT.TableCaption(), JT.FieldCaption("Contrato No."), JT."Contrato No.",
                JT.FieldCaption("Contrato Task No."), JT."Contrato Task No.");
            Error(Txt);
        end;
    end;

    procedure ChangeGLAccNo(var JobPlanningLine: Record "Contrato Planning Line")
    var
        GLAcc: Record "G/L Account";
        Contrato: Record Contrato;
        JT: Record "Contrato Task";
        JobPostingGr: Record "Contrato Posting Group";
        Cust: Record Customer;
    begin
        JT.Get(JobPlanningLine."Contrato No.", JobPlanningLine."Contrato Task No.");
        Contrato.Get(JobPlanningLine."Contrato No.");
        GetBillToCustomer(Contrato, JobPlanningLine, Cust);
        if JT."Contrato Posting Group" <> '' then
            JobPostingGr.Get(JT."Contrato Posting Group")
        else begin
            Contrato.TestField("Contrato Posting Group");
            JobPostingGr.Get(Contrato."Contrato Posting Group");
        end;
        if JobPostingGr."G/L Expense Acc. (Contract)" = '' then
            exit;
        GLAcc.Get(JobPostingGr."G/L Expense Acc. (Contract)");
        GLAcc.CheckGLAcc();
        JobPlanningLine."No." := GLAcc."No.";
        JobPlanningLine."Gen. Bus. Posting Group" := Cust."Gen. Bus. Posting Group";
        JobPlanningLine."Gen. Prod. Posting Group" := GLAcc."Gen. Prod. Posting Group";
    end;

    local procedure GetBillToCustomer(Contrato: Record Contrato; var JobPlanningLine: Record "Contrato Planning Line"; var Cust: Record Customer)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetBillToCustomer(JobPlanningLine, Cust, IsHandled);
        if IsHandled then
            exit;

        Cust.Get(Contrato."Bill-to Customer No.");
    end;

    procedure CheckItemQuantityPurchCredit(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line")
    var
        Item: Record Item;
        Contrato: Record Contrato;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckItemQuantityPurchCredit(PurchaseHeader, PurchaseLine, IsHandled);
        if IsHandled then
            exit;

        Contrato.Get(PurchaseLine."Job No.");
        if Contrato.GetQuantityAvailable(PurchaseLine."No.", PurchaseLine."Location Code", PurchaseLine."Variant Code", 0, 2) <
           -PurchaseLine."Return Qty. to Ship (Base)"
        then
            Error(
              Text005, Item.TableCaption(), PurchaseLine."No.", Contrato.TableCaption(),
              PurchaseLine."Job No.", PurchaseHeader."No.",
              PurchaseLine.FieldCaption("Line No."), PurchaseLine."Line No.");
    end;

#if not CLEAN23

    procedure PostPurchaseGLAccounts(TempInvoicePostBuffer: Record "Invoice Posting Buffer" temporary; GLEntryNo: Integer)
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        IsHandled: Boolean;
    begin
        TempPurchaseLineJob.Reset();
        TempPurchaseLineJob.SetRange("Job No.", TempInvoicePostBuffer."Job No.");
        TempPurchaseLineJob.SetRange("No.", TempInvoicePostBuffer."G/L Account");
        TempPurchaseLineJob.SetRange("Gen. Bus. Posting Group", TempInvoicePostBuffer."Gen. Bus. Posting Group");
        TempPurchaseLineJob.SetRange("Gen. Prod. Posting Group", TempInvoicePostBuffer."Gen. Prod. Posting Group");
        TempPurchaseLineJob.SetRange("VAT Bus. Posting Group", TempInvoicePostBuffer."VAT Bus. Posting Group");
        TempPurchaseLineJob.SetRange("VAT Prod. Posting Group", TempInvoicePostBuffer."VAT Prod. Posting Group");
        TempPurchaseLineJob.SetRange("Dimension Set ID", TempInvoicePostBuffer."Dimension Set ID");

        if TempInvoicePostBuffer."Fixed Asset Line No." <> 0 then begin
            PurchasesPayablesSetup.SetLoadFields("Copy Line Descr. to G/L Entry");
            PurchasesPayablesSetup.Get();
            if PurchasesPayablesSetup."Copy Line Descr. to G/L Entry" then
                TempPurchaseLineJob.SetRange("Line No.", TempInvoicePostBuffer."Fixed Asset Line No.");
        end;

        OnPostPurchaseGLAccountsOnAfterTempPurchaseLineJobSetFilters(TempPurchaseLineJob, TempInvoicePostBuffer);
        if TempPurchaseLineJob.FindSet() then begin
            repeat
                TempJobJournalLine.Reset();
                TempJobJournalLine.SetRange("Line No.", TempPurchaseLineJob."Line No.");
                TempJobJournalLine.FindFirst();
                JobJnlPostLine.SetGLEntryNo(GLEntryNo);
                IsHandled := false;
                OnPostPurchaseGLAccountsOnBeforeJobJnlPostLine(TempJobJournalLine, TempPurchaseLineJob, IsHandled);
                if not IsHandled then
                    JobJnlPostLine.RunWithCheck(TempJobJournalLine);
            until TempPurchaseLineJob.Next() = 0;
            TempPurchaseLineJob.DeleteAll();
        end;
        OnAfterPostPurchaseGLAccounts(TempInvoicePostBuffer, JobJnlPostLine, GLEntryNo);
    end;
#endif

    procedure PostJobPurchaseLines(JobLineFilters: Text; GLEntryNo: Integer)
    var
        IsHandled: Boolean;
    begin
        TempPurchaseLineJob.Reset();
        TempPurchaseLineJob.SetView(JobLineFilters);
        if TempPurchaseLineJob.FindSet() then begin
            repeat
                TempJobJournalLine.Reset();
                TempJobJournalLine.SetRange("Line No.", TempPurchaseLineJob."Line No.");
                TempJobJournalLine.FindFirst();
                JobJnlPostLine.SetGLEntryNo(GLEntryNo);
                IsHandled := false;
                OnPostJobPurchaseLinesOnBeforeJobJnlPostLine(TempJobJournalLine, TempPurchaseLineJob, IsHandled);
                if not IsHandled then
                    JobJnlPostLine.RunWithCheck(TempJobJournalLine);
                OnPostJobPurchaseLinesOnAfterJobJnlPostLine(TempJobJournalLine, TempPurchaseLineJob);
            until TempPurchaseLineJob.Next() = 0;
            TempPurchaseLineJob.DeleteAll();
        end;

        OnAfterPostJobPurchaseLines(TempPurchaseLineJob, JobJnlPostLine, GLEntryNo);
        TempPurchaseLineJob.DeleteAll();
    end;

#if not CLEAN23
    procedure PostSalesGLAccounts(TempInvoicePostBuffer: Record "Invoice Posting Buffer" temporary; GLEntryNo: Integer)
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        TempSalesLineJob.Reset();
        TempSalesLineJob.SetRange("Job No.", TempInvoicePostBuffer."Job No.");
        TempSalesLineJob.SetRange("No.", TempInvoicePostBuffer."G/L Account");
        TempSalesLineJob.SetRange("Gen. Bus. Posting Group", TempInvoicePostBuffer."Gen. Bus. Posting Group");
        TempSalesLineJob.SetRange("Gen. Prod. Posting Group", TempInvoicePostBuffer."Gen. Prod. Posting Group");
        TempSalesLineJob.SetRange("VAT Bus. Posting Group", TempInvoicePostBuffer."VAT Bus. Posting Group");
        TempSalesLineJob.SetRange("VAT Prod. Posting Group", TempInvoicePostBuffer."VAT Prod. Posting Group");

        if TempInvoicePostBuffer."Fixed Asset Line No." <> 0 then begin
            SalesReceivablesSetup.SetLoadFields("Copy Line Descr. to G/L Entry");
            SalesReceivablesSetup.Get();
            if SalesReceivablesSetup."Copy Line Descr. to G/L Entry" then
                TempSalesLineJob.SetRange("Line No.", TempInvoicePostBuffer."Fixed Asset Line No.");
        end;

        if TempSalesLineJob.FindSet() then begin
            repeat
                TempJobJournalLine.Reset();
                TempJobJournalLine.SetRange("Line No.", TempSalesLineJob."Line No.");
                TempJobJournalLine.FindFirst();
                JobJnlPostLine.SetGLEntryNo(GLEntryNo);
                OnPostSalesGLAccountsOnBeforeJobJnlPostLine(TempJobJournalLine, TempSalesLineJob);
                PostSalesJobJournalLine(TempJobJournalLine);
            until TempSalesLineJob.Next() = 0;
            TempSalesLineJob.DeleteAll();
        end;
    end;
#endif

    procedure PostJobSalesLines(JobLineFilters: Text; GLEntryNo: Integer)
    var
        IsHandled: Boolean;
    begin
        TempSalesLineJob.Reset();
        TempSalesLineJob.SetView(JobLineFilters);
        if TempSalesLineJob.FindSet() then begin
            repeat
                TempJobJournalLine.Reset();
                TempJobJournalLine.SetRange("Line No.", TempSalesLineJob."Line No.");
                TempJobJournalLine.FindFirst();
                JobJnlPostLine.SetGLEntryNo(GLEntryNo);
                IsHandled := false;
                OnPostJobSalesLinesOnBeforeJobJnlPostLine(TempJobJournalLine, TempSalesLineJob, IsHandled);
                if not IsHandled then
                    PostSalesJobJournalLine(TempJobJournalLine);
            until TempSalesLineJob.Next() = 0;
            TempSalesLineJob.DeleteAll();
        end;
    end;

    local procedure InsertTempJobJournalLine(JobJournalLine: Record "Contrato Journal Line"; LineNo: Integer)
    begin
        TempJobJournalLine := JobJournalLine;
        TempJobJournalLine."Line No." := LineNo;
        TempJobJournalLine.Insert();
    end;

    local procedure CheckCurrency(Contrato: Record Contrato; SalesHeader: Record "Sales Header"; JobPlanningLine: Record "Contrato Planning Line")
    var
        JobTask: Record "Contrato Task";
        JobInvCurr: Code[10];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckCurrency(Contrato, SalesHeader, JobPlanningLine, IsHandled);
        if IsHandled then
            exit;

        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
            JobInvCurr := Contrato."Invoice Currency Code"
        else begin
            JobTask.Get(JobPlanningLine."Contrato No.", JobPlanningLine."Contrato Task No.");
            JobInvCurr := JobTask."Invoice Currency Code";
        end;

        if JobInvCurr = '' then begin
            Contrato.TestField("Currency Code", SalesHeader."Currency Code");
            Contrato.TestField("Currency Code", JobPlanningLine."Currency Code");
            SalesHeader.TestField("Currency Code", JobPlanningLine."Currency Code");
            SalesHeader.TestField("Currency Factor", JobPlanningLine."Currency Factor");
        end else begin
            Contrato.TestField("Currency Code", '');
            JobPlanningLine.TestField("Currency Code", '');
        end;
    end;

    local procedure PostSalesJobJournalLine(var JobJournalLine: Record "Contrato Journal Line")
    var
        JobLedgerEntryNo: Integer;
    begin
        JobLedgerEntryNo := JobJnlPostLine.RunWithCheck(JobJournalLine);
        UpdateJobLedgerEntryNoOnJobPlanLineInvoice(JobJournalLine, JobLedgerEntryNo);
    end;

    local procedure UpdateJobLedgerEntryNoOnJobPlanLineInvoice(JobJournalLine: Record "Contrato Journal Line"; JobLedgerEntryNo: Integer)
    var
        JobPlanningLineInvoice: Record "Contrato Planning Line Invoice";
    begin
        JobPlanningLineInvoice.SetRange("Contrato No.", JobJournalLine."Contrato No.");
        JobPlanningLineInvoice.SetRange("Contrato Task No.", JobJournalLine."Contrato Task No.");
        JobPlanningLineInvoice.SetRange("Document No.", JobJournalLine."Document No.");
        JobPlanningLineInvoice.SetRange("Line No.", JobJournalLine."Line No.");
        if JobPlanningLineInvoice.FindFirst() then begin
            JobPlanningLineInvoice."Contrato Ledger Entry No." := JobLedgerEntryNo;
            JobPlanningLineInvoice.Modify();
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostInvoiceContractLine(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;

#if not CLEAN23
    [IntegrationEvent(true, false)]
    local procedure OnAfterPostPurchaseGLAccounts(TempInvoicePostBuffer: Record "Invoice Posting Buffer" temporary; var JobJnlPostLine: Codeunit "Contrato Jnl.-Post Line"; GLEntryNo: Integer)
    begin
    end;
#endif

    [IntegrationEvent(true, false)]
    local procedure OnAfterPostJobPurchaseLines(var TempPurchaseLineJob: Record "Purchase Line" temporary; var JobJnlPostLine: Codeunit "Contrato Jnl.-Post Line"; GLEntryNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckItemQuantityPurchCredit(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetBillToCustomer(var JobPlanningLine: Record "Contrato Planning Line"; var Cust: Record Customer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostGenJnlLine(var JobJournalLine: Record "Contrato Journal Line"; GenJournalLine: Record "Gen. Journal Line"; GLEntry: Record "G/L Entry"; var IsHandled: Boolean; var JobJnlPostLine: Codeunit "Contrato Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPlLineFromLedgEntry(var JobLedgerEntry: Record "Contrato Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeJobPlanningLineUpdateQtyToInvoice(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var JobPlanningLine: Record "Contrato Planning Line"; var JobPlanningLineInvoice: Record "Contrato Planning Line Invoice"; JobLedgerEntryNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostInvoiceContractLine(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostInvoiceContractLineOnBeforeJobPlanningLineFindFirst(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var JobPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostJobOnPurchaseLine(var PurchHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var PurchLine: Record "Purchase Line"; var JobJnlLine: Record "Contrato Journal Line"; var IsHandled: Boolean; var TempPurchaseLineJob: Record "Purchase Line"; var TempJobJournalLine: Record "Contrato Journal Line"; var Sourcecode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestSalesLine(var SalesLine: Record "Sales Line"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateRelationship(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var JobPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterJobPlanningLineModify(var JobPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostGenJnlLineOnAfterTransferToJnlLine(var JobJnlLine: Record "Contrato Journal Line"; GenJnlLine: Record "Gen. Journal Line"; var JobJnlPostLine: Codeunit "Contrato Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostInvoiceContractLineBeforeCheckJobLine(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var JobPlanningLine: Record "Contrato Planning Line"; var JobLineChecked: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostInvoiceContractLineOnBeforeCheckBillToCustomer(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var JobPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

#if not CLEAN23
    [IntegrationEvent(false, false)]
    local procedure OnPostPurchaseGLAccountsOnAfterTempPurchaseLineJobSetFilters(var TempPurchaseLineJob: Record "Purchase Line" temporary; var TempInvoicePostBuffer: Record "Invoice Posting Buffer" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostPurchaseGLAccountsOnBeforeJobJnlPostLine(var JobJournalLine: Record "Contrato Journal Line"; PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnPostJobPurchaseLinesOnAfterJobJnlPostLine(var TempJobJournalLine: Record "Contrato Journal Line" temporary; TempJobPurchaseLine: Record "Purchase Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostJobPurchaseLinesOnBeforeJobJnlPostLine(var TempJobJournalLine: Record "Contrato Journal Line" temporary; TempJobPurchaseLine: Record "Purchase Line" temporary; var IsHandled: Boolean)
    begin
    end;

#if not CLEAN23
    [IntegrationEvent(false, false)]
    local procedure OnPostSalesGLAccountsOnBeforeJobJnlPostLine(var JobJournalLine: Record "Contrato Journal Line"; SalesLine: Record "Sales Line")
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnPostJobSalesLinesOnBeforeJobJnlPostLine(var TempJobJournalLine: Record "Contrato Journal Line" temporary; var TempJobSalesLine: Record "Sales Line" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostJobOnPurchaseLineOnAfterCalcShouldSkipLine(PurchaseLine: Record "Purchase Line"; var ShouldSkipLine: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostJobOnPurchaseLineOnAfterJobTransferLineFromPurchaseLineToJnlLine(var PurchHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; PurchLine: Record "Purchase Line"; var JobJnlLine: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateRelationshipOnBeforeCheckLineDiscount(var SalesLine: Record "Sales Line"; var JobPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckCurrency(Contrato: Record Contrato; SalesHeader: Record "Sales Header"; JobPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnPostGenJnlLineOnBeforeGenJnlCheck(var JobJournalLine: Record "Contrato Journal Line"; GenJournalLine: Record "Gen. Journal Line"; GLEntry: Record "G/L Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostPlanningLineOnBeforeJobPlanningLineInsert(var JobPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPlanningLine(var JobPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostInvoiceContractLineOnBeforePostJobOnSalesLine(JobPlanningLine: Record "Contrato Planning Line"; JobPlanningLineInvoice: Record "Contrato Planning Line Invoice"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPlLineFromLedgEntry(JobLedgerEntry: Record "Contrato Ledger Entry"; var JobPlanningLine: Record "Contrato Planning Line")
    begin
    end;
}

