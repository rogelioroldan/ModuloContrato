codeunit 50202 "Contrato Post-Line"
{
    Permissions = TableData "Contrato Ledger Entry" = rm,
                  TableData "Contrato Planning Line" = rimd;

    trigger OnRun()
    begin
    end;

    var
        TempSalesLineContrato: Record "Sales Line" temporary;
        TempPurchaseLineContrato: Record "Purchase Line" temporary;
        TempContratoJournalLine: Record "Contrato Journal Line" temporary;
        ContratoJnlPostLine: Codeunit "Contrato Jnl.-Post Line";
        ContratoTransferLine: Codeunit "Contrato Transfer Line";
        UOMMgt: Codeunit "Unit of Measure Management";
        Text000: Label 'has been changed (initial a %1: %2= %3, %4= %5)';
        Text003: Label 'You cannot change the sales line because it is linked to\';
        Text004: Label ' %1: %2= %3, %4= %5.';
        Text005: Label 'You must post more usage or credit the sale of %1 %2 in %3 %4 before you can post purchase credit memo %5 %6 = %7.';

    procedure InsertPlLineFromLedgEntry(var ContratoLedgEntry: Record "Contrato Ledger Entry")
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
        IsHandled: Boolean;
    begin
        OnBeforeInsertPlLineFromLedgEntry(ContratoLedgEntry, IsHandled);
        if not IsHandled then begin
            if ContratoLedgEntry."Line Type" = ContratoLedgEntry."Line Type"::" " then
                exit;
            ClearAll();
            ContratoPlanningLine."Contrato No." := ContratoLedgEntry."Contrato No.";
            ContratoPlanningLine."Contrato Task No." := ContratoLedgEntry."Contrato Task No.";
            ContratoPlanningLine.SetRange("Contrato No.", ContratoPlanningLine."Contrato No.");
            ContratoPlanningLine.SetRange("Contrato Task No.", ContratoPlanningLine."Contrato Task No.");
            if ContratoPlanningLine.FindLast() then;
            ContratoPlanningLine."Line No." := ContratoPlanningLine."Line No." + 10000;
            ContratoPlanningLine.Init();
            ContratoPlanningLine.Reset();
            Clear(ContratoTransferLine);
            ContratoTransferLine.FromContratoLedgEntryToPlanningLine(ContratoLedgEntry, ContratoPlanningLine);
            PostPlanningLine(ContratoPlanningLine);
        end;

        OnAfterInsertPlLineFromLedgEntry(ContratoLedgEntry, ContratoPlanningLine);
    end;

    procedure PostPlanningLine(var ContratoPlanningLine: Record "Contrato Planning Line")
    var
        Contrato: Record Contrato;
    begin
        OnBeforePostPlanningLine(ContratoPlanningLine);

        if ContratoPlanningLine."Line Type" = ContratoPlanningLine."Line Type"::"Both Budget and Billable" then begin
            Contrato.Get(ContratoPlanningLine."Contrato No.");
            if not Contrato."Allow Schedule/Contract Lines" or
               (ContratoPlanningLine.Type = ContratoPlanningLine.Type::"G/L Account")
            then begin
                ContratoPlanningLine.Validate("Line Type", ContratoPlanningLine."Line Type"::Budget);
                ContratoPlanningLine.Insert(true);
                InsertContratoUsageLink(ContratoPlanningLine);
                ContratoPlanningLine.Validate("Qty. to Transfer to Journal", 0);
                ContratoPlanningLine.Modify(true);
                ContratoPlanningLine."Contrato Contract Entry No." := 0;
                ContratoPlanningLine."Line No." := ContratoPlanningLine."Line No." + 10000;
                ContratoPlanningLine.Validate("Line Type", ContratoPlanningLine."Line Type"::Billable);
            end;
        end;
        if (ContratoPlanningLine.Type = ContratoPlanningLine.Type::"G/L Account") and
           (ContratoPlanningLine."Line Type" = ContratoPlanningLine."Line Type"::Billable)
        then
            ChangeGLAccNo(ContratoPlanningLine);
        OnPostPlanningLineOnBeforeContratoPlanningLineInsert(ContratoPlanningLine);
        ContratoPlanningLine.Insert(true);
        ContratoPlanningLine.Validate("Qty. to Transfer to Journal", 0);
        ContratoPlanningLine.Modify(true);
        if ContratoPlanningLine."Line Type" in
           [ContratoPlanningLine."Line Type"::Budget, ContratoPlanningLine."Line Type"::"Both Budget and Billable"]
        then
            InsertContratoUsageLink(ContratoPlanningLine);
    end;

    local procedure InsertContratoUsageLink(var ContratoPlanningLine: Record "Contrato Planning Line")
    var
        ContratoUsageLink: Record "Contrato Usage Link";
        ContratoLedgerEntry: Record "Contrato Ledger Entry";
    begin
        if not ContratoPlanningLine."Usage Link" then
            exit;
        ContratoLedgerEntry.Get(ContratoPlanningLine."Contrato Ledger Entry No.");
        if UsageLinkExist(ContratoLedgerEntry) then
            exit;
        ContratoUsageLink.Create(ContratoPlanningLine, ContratoLedgerEntry);

        ContratoPlanningLine.Use(
            UOMMgt.CalcQtyFromBase(
                ContratoPlanningLine."No.", ContratoPlanningLine."Variant Code", ContratoPlanningLine."Unit of Measure Code",
                ContratoLedgerEntry."Quantity (Base)", ContratoPlanningLine."Qty. per Unit of Measure"),
            ContratoLedgerEntry."Total Cost", ContratoLedgerEntry."Line Amount", ContratoLedgerEntry."Posting Date", ContratoLedgerEntry."Currency Factor");
    end;

    local procedure UsageLinkExist(ContratoLedgEntry: Record "Contrato Ledger Entry"): Boolean
    var
        ContratoUsageLink: Record "Contrato Usage Link";
    begin
        ContratoUsageLink.SetRange("Contrato No.", ContratoLedgEntry."Contrato No.");
        ContratoUsageLink.SetRange("Contrato Task No.", ContratoLedgEntry."Contrato Task No.");
        ContratoUsageLink.SetRange("Entry No.", ContratoLedgEntry."Entry No.");
        if not ContratoUsageLink.IsEmpty then
            exit(true);
    end;

    procedure PostInvoiceContractLine(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")
    var
        Contrato: Record Contrato;
        ContratoTask: Record "Contrato Task";
        ContratoPlanningLine: Record "Contrato Planning Line";
        ContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice";
        DummyContratoLedgEntryNo: Integer;
        ContratoLineChecked: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostInvoiceContractLine(SalesHeader, SalesLine, IsHandled);
        if IsHandled then
            exit;

        ContratoPlanningLine.SetCurrentKey("Contrato Contract Entry No.");
        ContratoPlanningLine.SetRange("Contrato Contract Entry No.", SalesLine."Job Contract Entry No.");
        OnPostInvoiceContractLineOnBeforeContratoPlanningLineFindFirst(SalesHeader, SalesLine, ContratoPlanningLine);
        ContratoPlanningLine.FindFirst();
        Contrato.Get(ContratoPlanningLine."Contrato No.");

        CheckCurrency(Contrato, SalesHeader, ContratoPlanningLine);

        IsHandled := false;
        OnPostInvoiceContractLineOnBeforeCheckBillToCustomer(SalesHeader, SalesLine, ContratoPlanningLine, IsHandled);
        if not IsHandled then
            if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
                SalesHeader.TestField("Bill-to Customer No.", Contrato."Bill-to Customer No.")
            else begin
                ContratoTask.Get(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.");
                SalesHeader.TestField("Bill-to Customer No.", ContratoTask."Bill-to Customer No.");
            end;

        OnPostInvoiceContractLineBeforeCheckContratoLine(SalesHeader, SalesLine, ContratoPlanningLine, ContratoLineChecked);
        if not ContratoLineChecked then begin
            ContratoPlanningLine.CalcFields("Qty. Transferred to Invoice");
            if ContratoPlanningLine.Type <> ContratoPlanningLine.Type::Text then
                ContratoPlanningLine.TestField("Qty. Transferred to Invoice");
        end;

        ValidateRelationship(SalesHeader, SalesLine, ContratoPlanningLine);

        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Invoice:
                if ContratoPlanningLineInvoice.Get(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.", ContratoPlanningLine."Line No.",
                     ContratoPlanningLineInvoice."Document Type"::Invoice, SalesHeader."No.", SalesLine."Line No.")
                then begin
                    ContratoPlanningLineInvoice.Delete(true);
                    ContratoPlanningLineInvoice."Document Type" := ContratoPlanningLineInvoice."Document Type"::"Posted Invoice";
                    ContratoPlanningLineInvoice."Document No." := SalesLine."Document No.";
                    ContratoPlanningLineInvoice.Insert(true);

                    ContratoPlanningLineInvoice."Invoiced Date" := SalesHeader."Posting Date";
                    ContratoPlanningLineInvoice."Invoiced Amount (LCY)" :=
                      CalcLineAmountLCY(ContratoPlanningLine, ContratoPlanningLineInvoice."Quantity Transferred");
                    ContratoPlanningLineInvoice."Invoiced Cost Amount (LCY)" :=
                      ContratoPlanningLineInvoice."Quantity Transferred" * ContratoPlanningLine."Unit Cost (LCY)";
                    ContratoPlanningLineInvoice.Modify();
                end;
            SalesHeader."Document Type"::"Credit Memo":
                if ContratoPlanningLineInvoice.Get(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.", ContratoPlanningLine."Line No.",
                     ContratoPlanningLineInvoice."Document Type"::"Credit Memo", SalesHeader."No.", SalesLine."Line No.")
                then begin
                    ContratoPlanningLineInvoice.Delete(true);
                    ContratoPlanningLineInvoice."Document Type" := ContratoPlanningLineInvoice."Document Type"::"Posted Credit Memo";
                    ContratoPlanningLineInvoice."Document No." := SalesLine."Document No.";
                    ContratoPlanningLineInvoice.Insert(true);

                    ContratoPlanningLineInvoice."Invoiced Date" := SalesHeader."Posting Date";
                    ContratoPlanningLineInvoice."Invoiced Amount (LCY)" :=
                      CalcLineAmountLCY(ContratoPlanningLine, ContratoPlanningLineInvoice."Quantity Transferred");
                    ContratoPlanningLineInvoice."Invoiced Cost Amount (LCY)" :=
                      ContratoPlanningLineInvoice."Quantity Transferred" * ContratoPlanningLine."Unit Cost (LCY)";
                    ContratoPlanningLineInvoice.Modify();
                end;
        end;

        OnBeforeContratoPlanningLineUpdateQtyToInvoice(SalesHeader, SalesLine, ContratoPlanningLine, ContratoPlanningLineInvoice, DummyContratoLedgEntryNo);

        ContratoPlanningLine.UpdateQtyToInvoice();
        ContratoPlanningLine.Modify();

        OnAfterContratoPlanningLineModify(ContratoPlanningLine);

        IsHandled := false;
        OnPostInvoiceContractLineOnBeforePostContratoOnSalesLine(ContratoPlanningLine, ContratoPlanningLineInvoice, SalesHeader, SalesLine, IsHandled);
        if not IsHandled then
            if ContratoPlanningLine.Type <> ContratoPlanningLine.Type::Text then
                PostContratoOnSalesLine(ContratoPlanningLine, SalesHeader, SalesLine, ContratoJournalLineEntryType::Sale);

        OnAfterPostInvoiceContractLine(SalesHeader, SalesLine);
    end;

    local procedure ValidateRelationship(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; ContratoPlanningLine: Record "Contrato Planning Line")
    var
        ContratoTask: Record "Contrato Task";
        Txt: Text[500];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeValidateRelationship(SalesHeader, SalesLine, ContratoPlanningLine, IsHandled);
        if IsHandled then
            exit;

        ContratoTask.Get(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.");
        Txt := StrSubstNo(Text000,
            ContratoTask.TableCaption(), ContratoTask.FieldCaption("Contrato No."), ContratoTask."Contrato No.",
            ContratoTask.FieldCaption("Contrato Task No."), ContratoTask."Contrato Task No.");

        if ContratoPlanningLine.Type = ContratoPlanningLine.Type::Text then
            if SalesLine.Type <> SalesLine.Type::" " then
                SalesLine.FieldError(Type, Txt);
        if ContratoPlanningLine.Type = ContratoPlanningLine.Type::Resource then
            if SalesLine.Type <> SalesLine.Type::Resource then
                SalesLine.FieldError(Type, Txt);
        if ContratoPlanningLine.Type = ContratoPlanningLine.Type::Item then
            if SalesLine.Type <> SalesLine.Type::Item then
                SalesLine.FieldError(Type, Txt);
        if ContratoPlanningLine.Type = ContratoPlanningLine.Type::"G/L Account" then
            if SalesLine.Type <> SalesLine.Type::"G/L Account" then
                SalesLine.FieldError(Type, Txt);

        if SalesLine."No." <> ContratoPlanningLine."No." then
            SalesLine.FieldError("No.", Txt);
        if SalesLine."Location Code" <> ContratoPlanningLine."Location Code" then
            SalesLine.FieldError("Location Code", Txt);
        if SalesLine."Work Type Code" <> ContratoPlanningLine."Work Type Code" then
            SalesLine.FieldError("Work Type Code", Txt);
        if SalesLine."Unit of Measure Code" <> ContratoPlanningLine."Unit of Measure Code" then
            SalesLine.FieldError("Unit of Measure Code", Txt);
        if SalesLine."Variant Code" <> ContratoPlanningLine."Variant Code" then
            SalesLine.FieldError("Variant Code", Txt);
        if SalesLine."Gen. Prod. Posting Group" <> ContratoPlanningLine."Gen. Prod. Posting Group" then
            SalesLine.FieldError("Gen. Prod. Posting Group", Txt);

        IsHandled := false;
        OnValidateRelationshipOnBeforeCheckLineDiscount(SalesLine, ContratoPlanningLine, IsHandled);
        if not IsHandled then
            if SalesLine."Line Discount %" <> ContratoPlanningLine."Line Discount %" then
                SalesLine.FieldError("Line Discount %", Txt);
        if SalesLine."Unit Cost (LCY)" <> ContratoPlanningLine."Unit Cost (LCY)" then
            SalesLine.FieldError("Unit Cost (LCY)", Txt);
        if SalesLine.Type = SalesLine.Type::" " then
            if SalesLine."Line Amount" <> 0 then
                SalesLine.FieldError("Line Amount", Txt);
        if SalesHeader."Prices Including VAT" then
            if ContratoPlanningLine."VAT %" <> SalesLine."VAT %" then
                SalesLine.FieldError("VAT %", Txt);
    end;

    procedure PostContratoOnSalesLine(ContratoPlanningLine: Record "Contrato Planning Line"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; EntryType: Enum ContratoJournalLineEntryType)
    var
        ContratoJnlLine: Record "Contrato Journal Line";
    begin
        ContratoTransferLine.FromPlanningSalesLineToJnlLine(ContratoPlanningLine, SalesHeader, SalesLine, ContratoJnlLine, EntryType);
        if SalesLine.Type = SalesLine.Type::"G/L Account" then begin
            TempSalesLineContrato := SalesLine;
            TempSalesLineContrato.Insert();
            InsertTempContratoJournalLine(ContratoJnlLine, TempSalesLineContrato."Line No.");
        end else
            PostSalesContratoJournalLine(ContratoJnlLine);
    end;

    procedure CalcLineAmountLCY(ContratoPlanningLine: Record "Contrato Planning Line"; Qty: Decimal): Decimal
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        TotalPrice: Decimal;
        UnitPriceLCY: Decimal;
    begin
        if ContratoPlanningLine."Currency Code" <> '' then
            UnitPriceLCY :=
              CurrencyExchangeRate.ExchangeAmtFCYToLCY(
                ContratoPlanningLine."Currency Date", ContratoPlanningLine."Currency Code",
                ContratoPlanningLine."Unit Price", ContratoPlanningLine."Currency Factor")
        else
            UnitPriceLCY := ContratoPlanningLine."Unit Price";

        TotalPrice := Round(Qty * UnitPriceLCY, 0.01);
        exit(TotalPrice - Round(TotalPrice * ContratoPlanningLine."Line Discount %" / 100, 0.01));
    end;

    procedure PostGenJnlLine(GenJnlLine: Record "Gen. Journal Line"; GLEntry: Record "G/L Entry")
    var
        ContratoJnlLine: Record "Contrato Journal Line";
        Contrato: Record Contrato;
        ContratoTask: Record "Contrato Task";
        SourceCodeSetup: Record "Source Code Setup";
        ContratoTransferLine: Codeunit "Contrato Transfer Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostGenJnlLine(ContratoJnlLine, GenJnlLine, GLEntry, IsHandled, ContratoJnlPostLine);
        if IsHandled then
            exit;

        OnPostGenJnlLineOnBeforeGenJnlCheck(ContratoJnlLine, GenJnlLine, GLEntry, IsHandled);
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
            ContratoTask.LockTable();
            Contrato.Get(GenJnlLine."Job No.");
            GenJnlLine.TestField("Job Currency Code", Contrato."Currency Code");
            ContratoTask.Get(GenJnlLine."Job No.", GenJnlLine."Job Task No.");
            ContratoTask.TestField("Contrato Task Type", ContratoTask."Contrato Task Type"::Posting);
        end;
        ContratoTransferLine.FromGenJnlLineToJnlLine(GenJnlLine, ContratoJnlLine);
        OnPostGenJnlLineOnAfterTransferToJnlLine(ContratoJnlLine, GenJnlLine, ContratoJnlPostLine);

        ContratoJnlPostLine.SetGLEntryNo(GLEntry."Entry No.");
        ContratoJnlPostLine.RunWithCheck(ContratoJnlLine);
        ContratoJnlPostLine.SetGLEntryNo(0);
    end;

    procedure PostContratoOnPurchaseLine(var PurchHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; PurchLine: Record "Purchase Line"; SourceCode: Code[10])
    var
        ContratoJnlLine: Record "Contrato Journal Line";
        Contrato: Record Contrato;
        ContratoTask: Record "Contrato Task";
        IsHandled: Boolean;
        ShouldSkipLine: Boolean;
    begin
        IsHandled := false;
        OnBeforePostContratoOnPurchaseLine(
            PurchHeader, PurchInvHeader, PurchCrMemoHdr, PurchLine, ContratoJnlLine, IsHandled,
            TempPurchaseLineContrato, TempContratoJournalLine, SourceCode);
        if IsHandled then
            exit;

        ShouldSkipLine := (PurchLine.Type <> PurchLine.Type::Item) and (PurchLine.Type <> PurchLine.Type::"G/L Account");
        OnPostContratoOnPurchaseLineOnAfterCalcShouldSkipLine(PurchLine, ShouldSkipLine);
        if ShouldSkipLine then
            exit;
        Clear(ContratoJnlLine);
        PurchLine.TestField("Job No.");
        PurchLine.TestField("Job Task No.");
        Contrato.LockTable();
        ContratoTask.LockTable();
        Contrato.Get(PurchLine."Job No.");
        PurchLine.TestField("Job Currency Code", Contrato."Currency Code");
        ContratoTask.Get(PurchLine."Job No.", PurchLine."Job Task No.");
        ContratoTransferLine.FromPurchaseLineToJnlLine(
          PurchHeader, PurchInvHeader, PurchCrMemoHdr, PurchLine, Sourcecode, ContratoJnlLine);
        OnPostContratoOnPurchaseLineOnAfterContratoTransferLineFromPurchaseLineToJnlLine(PurchHeader, PurchInvHeader, PurchCrMemoHdr, PurchLine, ContratoJnlLine);
        ContratoJnlLine."Contrato Posting Only" := true;

        if PurchLine.Type = PurchLine.Type::"G/L Account" then begin
            TempPurchaseLineContrato := PurchLine;
            TempPurchaseLineContrato.Insert();
            InsertTempContratoJournalLine(ContratoJnlLine, TempPurchaseLineContrato."Line No.");
        end else
            ContratoJnlPostLine.RunWithCheck(ContratoJnlLine);
    end;

    procedure TestSalesLine(var SalesLine: Record "Sales Line")
    var
        JT: Record "Contrato Task";
        ContratoPlanningLine: Record "Contrato Planning Line";
        Txt: Text[250];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestSalesLine(SalesLine, IsHandled);
        if IsHandled then
            exit;

        if SalesLine."Job Contract Entry No." = 0 then
            exit;
        ContratoPlanningLine.SetCurrentKey("Contrato Contract Entry No.");
        ContratoPlanningLine.SetRange("Contrato Contract Entry No.", SalesLine."Job Contract Entry No.");
        if ContratoPlanningLine.FindFirst() then begin
            JT.Get(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.");
            Txt := Text003 + StrSubstNo(Text004,
                JT.TableCaption(), JT.FieldCaption("Contrato No."), JT."Contrato No.",
                JT.FieldCaption("Contrato Task No."), JT."Contrato Task No.");
            Error(Txt);
        end;
    end;

    procedure ChangeGLAccNo(var ContratoPlanningLine: Record "Contrato Planning Line")
    var
        GLAcc: Record "G/L Account";
        Contrato: Record Contrato;
        JT: Record "Contrato Task";
        ContratoPostingGr: Record "Contrato Posting Group";
        Cust: Record Customer;
    begin
        JT.Get(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.");
        Contrato.Get(ContratoPlanningLine."Contrato No.");
        GetBillToCustomer(Contrato, ContratoPlanningLine, Cust);
        if JT."Contrato Posting Group" <> '' then
            ContratoPostingGr.Get(JT."Contrato Posting Group")
        else begin
            Contrato.TestField("Contrato Posting Group");
            ContratoPostingGr.Get(Contrato."Contrato Posting Group");
        end;
        if ContratoPostingGr."G/L Expense Acc. (Contract)" = '' then
            exit;
        GLAcc.Get(ContratoPostingGr."G/L Expense Acc. (Contract)");
        GLAcc.CheckGLAcc();
        ContratoPlanningLine."No." := GLAcc."No.";
        ContratoPlanningLine."Gen. Bus. Posting Group" := Cust."Gen. Bus. Posting Group";
        ContratoPlanningLine."Gen. Prod. Posting Group" := GLAcc."Gen. Prod. Posting Group";
    end;

    local procedure GetBillToCustomer(Contrato: Record Contrato; var ContratoPlanningLine: Record "Contrato Planning Line"; var Cust: Record Customer)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetBillToCustomer(ContratoPlanningLine, Cust, IsHandled);
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
        TempPurchaseLineContrato.Reset();
        TempPurchaseLineContrato.SetRange("Job No.", TempInvoicePostBuffer."Job No.");
        TempPurchaseLineContrato.SetRange("No.", TempInvoicePostBuffer."G/L Account");
        TempPurchaseLineContrato.SetRange("Gen. Bus. Posting Group", TempInvoicePostBuffer."Gen. Bus. Posting Group");
        TempPurchaseLineContrato.SetRange("Gen. Prod. Posting Group", TempInvoicePostBuffer."Gen. Prod. Posting Group");
        TempPurchaseLineContrato.SetRange("VAT Bus. Posting Group", TempInvoicePostBuffer."VAT Bus. Posting Group");
        TempPurchaseLineContrato.SetRange("VAT Prod. Posting Group", TempInvoicePostBuffer."VAT Prod. Posting Group");
        TempPurchaseLineContrato.SetRange("Dimension Set ID", TempInvoicePostBuffer."Dimension Set ID");

        if TempInvoicePostBuffer."Fixed Asset Line No." <> 0 then begin
            PurchasesPayablesSetup.SetLoadFields("Copy Line Descr. to G/L Entry");
            PurchasesPayablesSetup.Get();
            if PurchasesPayablesSetup."Copy Line Descr. to G/L Entry" then
                TempPurchaseLineContrato.SetRange("Line No.", TempInvoicePostBuffer."Fixed Asset Line No.");
        end;

        OnPostPurchaseGLAccountsOnAfterTempPurchaseLineContratoSetFilters(TempPurchaseLineContrato, TempInvoicePostBuffer);
        if TempPurchaseLineContrato.FindSet() then begin
            repeat
                TempContratoJournalLine.Reset();
                TempContratoJournalLine.SetRange("Line No.", TempPurchaseLineContrato."Line No.");
                TempContratoJournalLine.FindFirst();
                ContratoJnlPostLine.SetGLEntryNo(GLEntryNo);
                IsHandled := false;
                OnPostPurchaseGLAccountsOnBeforeContratoJnlPostLine(TempContratoJournalLine, TempPurchaseLineContrato, IsHandled);
                if not IsHandled then
                    ContratoJnlPostLine.RunWithCheck(TempContratoJournalLine);
            until TempPurchaseLineContrato.Next() = 0;
            TempPurchaseLineContrato.DeleteAll();
        end;
        OnAfterPostPurchaseGLAccounts(TempInvoicePostBuffer, ContratoJnlPostLine, GLEntryNo);
    end;
#endif

    procedure PostContratoPurchaseLines(ContratoLineFilters: Text; GLEntryNo: Integer)
    var
        IsHandled: Boolean;
    begin
        TempPurchaseLineContrato.Reset();
        TempPurchaseLineContrato.SetView(ContratoLineFilters);
        if TempPurchaseLineContrato.FindSet() then begin
            repeat
                TempContratoJournalLine.Reset();
                TempContratoJournalLine.SetRange("Line No.", TempPurchaseLineContrato."Line No.");
                TempContratoJournalLine.FindFirst();
                ContratoJnlPostLine.SetGLEntryNo(GLEntryNo);
                IsHandled := false;
                OnPostContratoPurchaseLinesOnBeforeContratoJnlPostLine(TempContratoJournalLine, TempPurchaseLineContrato, IsHandled);
                if not IsHandled then
                    ContratoJnlPostLine.RunWithCheck(TempContratoJournalLine);
                OnPostContratoPurchaseLinesOnAfterContratoJnlPostLine(TempContratoJournalLine, TempPurchaseLineContrato);
            until TempPurchaseLineContrato.Next() = 0;
            TempPurchaseLineContrato.DeleteAll();
        end;

        OnAfterPostContratoPurchaseLines(TempPurchaseLineContrato, ContratoJnlPostLine, GLEntryNo);
        TempPurchaseLineContrato.DeleteAll();
    end;

#if not CLEAN23
    procedure PostSalesGLAccounts(TempInvoicePostBuffer: Record "Invoice Posting Buffer" temporary; GLEntryNo: Integer)
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        TempSalesLineContrato.Reset();
        TempSalesLineContrato.SetRange("Job No.", TempInvoicePostBuffer."Job No.");
        TempSalesLineContrato.SetRange("No.", TempInvoicePostBuffer."G/L Account");
        TempSalesLineContrato.SetRange("Gen. Bus. Posting Group", TempInvoicePostBuffer."Gen. Bus. Posting Group");
        TempSalesLineContrato.SetRange("Gen. Prod. Posting Group", TempInvoicePostBuffer."Gen. Prod. Posting Group");
        TempSalesLineContrato.SetRange("VAT Bus. Posting Group", TempInvoicePostBuffer."VAT Bus. Posting Group");
        TempSalesLineContrato.SetRange("VAT Prod. Posting Group", TempInvoicePostBuffer."VAT Prod. Posting Group");

        if TempInvoicePostBuffer."Fixed Asset Line No." <> 0 then begin
            SalesReceivablesSetup.SetLoadFields("Copy Line Descr. to G/L Entry");
            SalesReceivablesSetup.Get();
            if SalesReceivablesSetup."Copy Line Descr. to G/L Entry" then
                TempSalesLineContrato.SetRange("Line No.", TempInvoicePostBuffer."Fixed Asset Line No.");
        end;

        if TempSalesLineContrato.FindSet() then begin
            repeat
                TempContratoJournalLine.Reset();
                TempContratoJournalLine.SetRange("Line No.", TempSalesLineContrato."Line No.");
                TempContratoJournalLine.FindFirst();
                ContratoJnlPostLine.SetGLEntryNo(GLEntryNo);
                OnPostSalesGLAccountsOnBeforeContratoJnlPostLine(TempContratoJournalLine, TempSalesLineContrato);
                PostSalesContratoJournalLine(TempContratoJournalLine);
            until TempSalesLineContrato.Next() = 0;
            TempSalesLineContrato.DeleteAll();
        end;
    end;
#endif

    procedure PostContratoSalesLines(ContratoLineFilters: Text; GLEntryNo: Integer)
    var
        IsHandled: Boolean;
    begin
        TempSalesLineContrato.Reset();
        TempSalesLineContrato.SetView(ContratoLineFilters);
        if TempSalesLineContrato.FindSet() then begin
            repeat
                TempContratoJournalLine.Reset();
                TempContratoJournalLine.SetRange("Line No.", TempSalesLineContrato."Line No.");
                TempContratoJournalLine.FindFirst();
                ContratoJnlPostLine.SetGLEntryNo(GLEntryNo);
                IsHandled := false;
                OnPostContratoSalesLinesOnBeforeContratoJnlPostLine(TempContratoJournalLine, TempSalesLineContrato, IsHandled);
                if not IsHandled then
                    PostSalesContratoJournalLine(TempContratoJournalLine);
            until TempSalesLineContrato.Next() = 0;
            TempSalesLineContrato.DeleteAll();
        end;
    end;

    local procedure InsertTempContratoJournalLine(ContratoJournalLine: Record "Contrato Journal Line"; LineNo: Integer)
    begin
        TempContratoJournalLine := ContratoJournalLine;
        TempContratoJournalLine."Line No." := LineNo;
        TempContratoJournalLine.Insert();
    end;

    local procedure CheckCurrency(Contrato: Record Contrato; SalesHeader: Record "Sales Header"; ContratoPlanningLine: Record "Contrato Planning Line")
    var
        ContratoTask: Record "Contrato Task";
        ContratoInvCurr: Code[10];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckCurrency(Contrato, SalesHeader, ContratoPlanningLine, IsHandled);
        if IsHandled then
            exit;

        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
            ContratoInvCurr := Contrato."Invoice Currency Code"
        else begin
            ContratoTask.Get(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.");
            ContratoInvCurr := ContratoTask."Invoice Currency Code";
        end;

        if ContratoInvCurr = '' then begin
            Contrato.TestField("Currency Code", SalesHeader."Currency Code");
            Contrato.TestField("Currency Code", ContratoPlanningLine."Currency Code");
            SalesHeader.TestField("Currency Code", ContratoPlanningLine."Currency Code");
            SalesHeader.TestField("Currency Factor", ContratoPlanningLine."Currency Factor");
        end else begin
            Contrato.TestField("Currency Code", '');
            ContratoPlanningLine.TestField("Currency Code", '');
        end;
    end;

    local procedure PostSalesContratoJournalLine(var ContratoJournalLine: Record "Contrato Journal Line")
    var
        ContratoLedgerEntryNo: Integer;
    begin
        ContratoLedgerEntryNo := ContratoJnlPostLine.RunWithCheck(ContratoJournalLine);
        UpdateContratoLedgerEntryNoOnContratoPlanLineInvoice(ContratoJournalLine, ContratoLedgerEntryNo);
    end;

    local procedure UpdateContratoLedgerEntryNoOnContratoPlanLineInvoice(ContratoJournalLine: Record "Contrato Journal Line"; ContratoLedgerEntryNo: Integer)
    var
        ContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice";
    begin
        ContratoPlanningLineInvoice.SetRange("Contrato No.", ContratoJournalLine."Contrato No.");
        ContratoPlanningLineInvoice.SetRange("Contrato Task No.", ContratoJournalLine."Contrato Task No.");
        ContratoPlanningLineInvoice.SetRange("Document No.", ContratoJournalLine."Document No.");
        ContratoPlanningLineInvoice.SetRange("Line No.", ContratoJournalLine."Line No.");
        if ContratoPlanningLineInvoice.FindFirst() then begin
            ContratoPlanningLineInvoice."Contrato Ledger Entry No." := ContratoLedgerEntryNo;
            ContratoPlanningLineInvoice.Modify();
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostInvoiceContractLine(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;

#if not CLEAN23
    [IntegrationEvent(true, false)]
    local procedure OnAfterPostPurchaseGLAccounts(TempInvoicePostBuffer: Record "Invoice Posting Buffer" temporary; var ContratoJnlPostLine: Codeunit "Contrato Jnl.-Post Line"; GLEntryNo: Integer)
    begin
    end;
#endif

    [IntegrationEvent(true, false)]
    local procedure OnAfterPostContratoPurchaseLines(var TempPurchaseLineContrato: Record "Purchase Line" temporary; var ContratoJnlPostLine: Codeunit "Contrato Jnl.-Post Line"; GLEntryNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckItemQuantityPurchCredit(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetBillToCustomer(var ContratoPlanningLine: Record "Contrato Planning Line"; var Cust: Record Customer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostGenJnlLine(var ContratoJournalLine: Record "Contrato Journal Line"; GenJournalLine: Record "Gen. Journal Line"; GLEntry: Record "G/L Entry"; var IsHandled: Boolean; var ContratoJnlPostLine: Codeunit "Contrato Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPlLineFromLedgEntry(var ContratoLedgerEntry: Record "Contrato Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeContratoPlanningLineUpdateQtyToInvoice(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var ContratoPlanningLine: Record "Contrato Planning Line"; var ContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice"; ContratoLedgerEntryNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostInvoiceContractLine(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostInvoiceContractLineOnBeforeContratoPlanningLineFindFirst(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostContratoOnPurchaseLine(var PurchHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var PurchLine: Record "Purchase Line"; var ContratoJnlLine: Record "Contrato Journal Line"; var IsHandled: Boolean; var TempPurchaseLineContrato: Record "Purchase Line"; var TempContratoJournalLine: Record "Contrato Journal Line"; var Sourcecode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestSalesLine(var SalesLine: Record "Sales Line"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateRelationship(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var ContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterContratoPlanningLineModify(var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostGenJnlLineOnAfterTransferToJnlLine(var ContratoJnlLine: Record "Contrato Journal Line"; GenJnlLine: Record "Gen. Journal Line"; var ContratoJnlPostLine: Codeunit "Contrato Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostInvoiceContractLineBeforeCheckContratoLine(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var ContratoPlanningLine: Record "Contrato Planning Line"; var ContratoLineChecked: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostInvoiceContractLineOnBeforeCheckBillToCustomer(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var ContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

#if not CLEAN23
    [IntegrationEvent(false, false)]
    local procedure OnPostPurchaseGLAccountsOnAfterTempPurchaseLineContratoSetFilters(var TempPurchaseLineContrato: Record "Purchase Line" temporary; var TempInvoicePostBuffer: Record "Invoice Posting Buffer" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostPurchaseGLAccountsOnBeforeContratoJnlPostLine(var ContratoJournalLine: Record "Contrato Journal Line"; PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnPostContratoPurchaseLinesOnAfterContratoJnlPostLine(var TempContratoJournalLine: Record "Contrato Journal Line" temporary; TempContratoPurchaseLine: Record "Purchase Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostContratoPurchaseLinesOnBeforeContratoJnlPostLine(var TempContratoJournalLine: Record "Contrato Journal Line" temporary; TempContratoPurchaseLine: Record "Purchase Line" temporary; var IsHandled: Boolean)
    begin
    end;

#if not CLEAN23
    [IntegrationEvent(false, false)]
    local procedure OnPostSalesGLAccountsOnBeforeContratoJnlPostLine(var ContratoJournalLine: Record "Contrato Journal Line"; SalesLine: Record "Sales Line")
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnPostContratoSalesLinesOnBeforeContratoJnlPostLine(var TempContratoJournalLine: Record "Contrato Journal Line" temporary; var TempContratoSalesLine: Record "Sales Line" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostContratoOnPurchaseLineOnAfterCalcShouldSkipLine(PurchaseLine: Record "Purchase Line"; var ShouldSkipLine: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostContratoOnPurchaseLineOnAfterContratoTransferLineFromPurchaseLineToJnlLine(var PurchHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; PurchLine: Record "Purchase Line"; var ContratoJnlLine: Record "Contrato Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateRelationshipOnBeforeCheckLineDiscount(var SalesLine: Record "Sales Line"; var ContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckCurrency(Contrato: Record Contrato; SalesHeader: Record "Sales Header"; ContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnPostGenJnlLineOnBeforeGenJnlCheck(var ContratoJournalLine: Record "Contrato Journal Line"; GenJournalLine: Record "Gen. Journal Line"; GLEntry: Record "G/L Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostPlanningLineOnBeforeContratoPlanningLineInsert(var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPlanningLine(var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostInvoiceContractLineOnBeforePostContratoOnSalesLine(ContratoPlanningLine: Record "Contrato Planning Line"; ContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPlLineFromLedgEntry(ContratoLedgerEntry: Record "Contrato Ledger Entry"; var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;
}

