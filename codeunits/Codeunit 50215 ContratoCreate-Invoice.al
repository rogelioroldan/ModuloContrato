codeunit 50215 "Contrato Create-Invoice"
{

    trigger OnRun()
    begin
    end;

    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        SalesHeader2: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TempContratoPlanningLine: Record "Contrato Planning Line" temporary;
        TempContratoPlanningLine2: Record "Contrato Planning Line" temporary;
        TransferExtendedText: Codeunit "Transfer Extended Text";
        ContratoInvCurrency: Boolean;
        UpdateExchangeRates: Boolean;
        NoOfSalesLinesCreated: Integer;

        Text000: Label 'The lines were successfully transferred to an invoice.';
        Text001: Label 'The lines were not transferred to an invoice.';
        Text002: Label 'There was no %1 with a %2 larger than 0. No lines were transferred.';
        Text003: Label '%1 may not be lower than %2 and may not exceed %3.';
        Text004: Label 'You must specify Invoice No. or New Invoice.';
        Text005: Label 'You must specify Credit Memo No. or New Invoice.';
        Text007: Label 'You must specify %1.';
        Text008: Label 'The lines were successfully transferred to a credit memo.';
        Text009: Label 'The selected planning lines must have the same %1.';
        Text010: Label 'The currency dates on all planning lines will be updated based on the invoice posting date because there is a difference in currency exchange rates. Recalculations will be based on the Exch. Calculation setup for the Cost and Price values for the project. Do you want to continue?';
        Text011: Label 'The currency exchange rate on all planning lines will be updated based on the exchange rate on the sales invoice. Do you want to continue?';
        Text012: Label 'The %1 %2 does not exist anymore. A printed copy of the document was created before the document was deleted.', Comment = 'The Sales Invoice Header 103001 does not exist in the system anymore. A printed copy of the document was created before deletion.';

    procedure CreateSalesInvoice(var ContratoPlanningLine: Record "Contrato Planning Line"; CrMemo: Boolean)
    var
        SalesHeader: Record "Sales Header";
        Contrato: Record Contrato;
        ContratoPlanningLine2: Record "Contrato Planning Line";
        GetSalesInvoiceNo: Report ContratoTransfertoSalesInvoice;
        GetSalesCrMemoNo: Report ContratoTransfertoCreditMemo;
        Done: Boolean;
        NewInvoice: Boolean;
        PostingDate: Date;
        DocumentDate: Date;
        InvoiceNo: Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnCreateSalesInvoiceOnBeforeRunReport(ContratoPlanningLine, Done, NewInvoice, PostingDate, InvoiceNo, IsHandled, CrMemo);
        if not IsHandled then
            if not CrMemo then begin
                //GetSalesInvoiceNo.SetCustomer(ContratoPlanningLine);
                GetSalesInvoiceNo.RunModal();
                IsHandled := false;
                OnBeforeGetInvoiceNo(ContratoPlanningLine, Done, NewInvoice, PostingDate, InvoiceNo, IsHandled);
                if not IsHandled then
                    GetSalesInvoiceNo.GetInvoiceNo(Done, NewInvoice, PostingDate, DocumentDate, InvoiceNo);
            end else begin
                //GetSalesCrMemoNo.SetCustomer(ContratoPlanningLine);
                GetSalesCrMemoNo.RunModal();
                IsHandled := false;
                OnBeforeGetCrMemoNo(ContratoPlanningLine, Done, NewInvoice, PostingDate, InvoiceNo, IsHandled);
                if not IsHandled then
                    GetSalesCrMemoNo.GetCreditMemoNo(Done, NewInvoice, PostingDate, DocumentDate, InvoiceNo);
            end;

        if Done then begin
            if (PostingDate = 0D) and NewInvoice then
                Error(Text007, SalesHeader.FieldCaption("Posting Date"));
            if (InvoiceNo = '') and not NewInvoice then begin
                if CrMemo then
                    Error(Text005);
                Error(Text004);
            end;

            Contrato.Get(ContratoPlanningLine."Contrato No.");
            if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
                CreateSalesInvoiceLines(
                    ContratoPlanningLine."Contrato No.", ContratoPlanningLine, InvoiceNo, NewInvoice, PostingDate, DocumentDate, CrMemo)
            else begin
                ContratoPlanningLine2.Copy(ContratoPlanningLine);
                ContratoPlanningLine2.SetCurrentKey("Contrato No.", "Contrato Task No.", "Line No.");
                ContratoPlanningLine2.FindSet();
                ContratoPlanningLine.Reset();
                repeat
                    ContratoPlanningLine.SetFilter("Contrato No.", ContratoPlanningLine2."Contrato No.");
                    ContratoPlanningLine.SetFilter("Contrato Task No.", ContratoPlanningLine2."Contrato Task No.");
                    ContratoPlanningLine.SetFilter("Line No.", '%1', ContratoPlanningLine2."Line No.");
                    ContratoPlanningLine.FindFirst();
                    CreateSalesInvoiceLines(ContratoPlanningLine."Contrato No.", ContratoPlanningLine, InvoiceNo, NewInvoice, PostingDate, DocumentDate, CrMemo);
                until ContratoPlanningLine2.Next() = 0;
            end;

            Commit();

            ShowMessageLinesTransferred(ContratoPlanningLine, CrMemo);
        end;
    end;

    local procedure ShowMessageLinesTransferred(ContratoPlanningLine: Record "Contrato Planning Line"; CrMemo: Boolean)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeShowMessageLinesTransferred(ContratoPlanningLine, CrMemo, IsHandled);
        if IsHandled then
            exit;

        if CrMemo then
            Message(Text008)
        else
            Message(Text000);
    end;
#if not CLEAN23

    procedure CreateSalesInvoiceLines(ContratoNo: Code[20]; var ContratoPlanningLineSource: Record "Contrato Planning Line"; InvoiceNo: Code[20]; NewInvoice: Boolean; PostingDate: Date; CreditMemo: Boolean)
    begin
        CreateSalesInvoiceLines(ContratoNo, ContratoPlanningLineSource, InvoiceNo, NewInvoice, PostingDate, 0D, CreditMemo);
    end;
#endif
    procedure CreateSalesInvoiceLines(ContratoNo: Code[20]; var ContratoPlanningLineSource: Record "Contrato Planning Line"; InvoiceNo: Code[20]; NewInvoice: Boolean; PostingDate: Date; DocumentDate: Date; CreditMemo: Boolean)
    var
        Contrato: Record Contrato;
        ContratoPlanningLine: Record "Contrato Planning Line";
        ContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice";
        LineCounter: Integer;
        LastError: Text;
    begin
        OnBeforeCreateSalesInvoiceLines(ContratoPlanningLineSource, InvoiceNo, NewInvoice, PostingDate, CreditMemo, NoOfSalesLinesCreated);

        ClearAll();
        Contrato.Get(ContratoNo);
        OnCreateSalesInvoiceLinesOnBeforeTestContrato(Contrato);
        // if Contrato.Blocked = Contrato.Blocked::All then
        //     Contrato.TestBlocked();
        if Contrato."Currency Code" = '' then
            ContratoInvCurrency := IsContratoInvCurrencyDependingOnBillingMethod(Contrato, ContratoPlanningLineSource);

        OnCreateSalesInvoiceLinesOnAfterSetContratoInvCurrency(Contrato, ContratoInvCurrency);
        CheckContratoBillToCustomer(ContratoPlanningLineSource, Contrato);

        if CreditMemo then
            SalesHeader2."Document Type" := SalesHeader2."Document Type"::"Credit Memo"
        else
            SalesHeader2."Document Type" := SalesHeader2."Document Type"::Invoice;

        OnCreateSalesInvoiceLinesOnAfterSetSalesDocumentType(SalesHeader2);

        if not NewInvoice then
            SalesHeader.Get(SalesHeader2."Document Type", InvoiceNo);

        OnCreateSalesInvoiceLinesOnBeforeContratoPlanningLineCopy(Contrato, ContratoPlanningLineSource, PostingDate);
        ContratoPlanningLine.Copy(ContratoPlanningLineSource);
        ContratoPlanningLine.SetCurrentKey("Contrato No.", "Contrato Task No.", "Line No.");

        OnCreateSalesInvoiceLinesOnBeforeContratoPlanningLineFindSet(ContratoPlanningLine, InvoiceNo, NewInvoice, PostingDate, CreditMemo);
        if ContratoPlanningLine.FindSet() then
            repeat
                if TransferLine(ContratoPlanningLine) then begin
                    LineCounter := LineCounter + 1;
                    if (ContratoPlanningLine."Contrato No." <> ContratoNo) and (not ContratoPlanningLineSource.GetSkipCheckForMultipleContratosOnSalesLine()) then
                        LastError := StrSubstNo(Text009, ContratoPlanningLine.FieldCaption("Contrato No."));
                    OnCreateSalesInvoiceLinesOnAfterValidateContratoPlanningLine(ContratoPlanningLine, LastError);
                    if LastError <> '' then
                        Error(LastError);
                    if NewInvoice then
                        TestExchangeRate(ContratoPlanningLine, PostingDate)
                    else
                        TestExchangeRate(ContratoPlanningLine, SalesHeader."Posting Date");
                end;
            until ContratoPlanningLine.Next() = 0;

        if LineCounter = 0 then
            Error(Text002,
              ContratoPlanningLine.TableCaption(),
              ContratoPlanningLine.FieldCaption("Qty. to Transfer to Invoice"));

        if NewInvoice then
            CreateSalesHeader(Contrato, PostingDate, DocumentDate, ContratoPlanningLine)
        else
            TestSalesHeader(SalesHeader, Contrato, ContratoPlanningLine);
        if ContratoPlanningLine.Find('-') then
            repeat
                if TransferLine(ContratoPlanningLine) then begin
                    if ContratoPlanningLine.Type in [ContratoPlanningLine.Type::Resource,
                                                ContratoPlanningLine.Type::Item,
                                                ContratoPlanningLine.Type::"G/L Account"]
                    then
                        ContratoPlanningLine.TestField("No.");

                    OnCreateSalesInvoiceLinesOnBeforeCreateSalesLine(
                      ContratoPlanningLine, SalesHeader, SalesHeader2, NewInvoice, NoOfSalesLinesCreated);
#if not CLEAN24
                    if not CreditMemo then
                        CheckContratoPlanningLineIsNegative(ContratoPlanningLine);
#endif

                    CreateSalesLine(ContratoPlanningLine);

                    ContratoPlanningLineInvoice.InitFromContratoPlanningLine(ContratoPlanningLine);
                    if NewInvoice then
                        ContratoPlanningLineInvoice.InitFromSales(SalesHeader, PostingDate, SalesLine."Line No.")
                    else
                        ContratoPlanningLineInvoice.InitFromSales(SalesHeader, SalesHeader."Posting Date", SalesLine."Line No.");
                    ContratoPlanningLineInvoice.Insert();

                    ContratoPlanningLine.UpdateQtyToTransfer();
                    OnCreateSalesInvoiceLinesOnBeforeContratoPlanningLineModify(ContratoPlanningLine);
                    ContratoPlanningLine.Modify();
                end;
            until ContratoPlanningLine.Next() = 0;

        ContratoPlanningLineSource.Get(
          ContratoPlanningLineSource."Contrato No.", ContratoPlanningLineSource."Contrato Task No.", ContratoPlanningLineSource."Line No.");
        ContratoPlanningLineSource.CalcFields("Qty. Transferred to Invoice");

        if NoOfSalesLinesCreated = 0 then
            Error(Text002, ContratoPlanningLine.TableCaption(), ContratoPlanningLine.FieldCaption("Qty. to Transfer to Invoice"));

        OnAfterCreateSalesInvoiceLines(SalesHeader, NewInvoice);
    end;

    local procedure CheckContratoBillToCustomer(var ContratoPlanningLineSource: Record "Contrato Planning Line"; Contrato: Record Contrato)
    var
        ContratoTask: Record "Contrato Task";
        Cust: Record Customer;
        BillToCustomerNo: Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckContratoBillToCustomer(ContratoPlanningLineSource, Contrato, IsHandled);
        if IsHandled then
            exit;
        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then begin
            Contrato.TestField("Bill-to Customer No.");
            BillToCustomerNo := Contrato."Bill-to Customer No.";
        end else begin
            ContratoTask.Get(ContratoPlanningLineSource."Contrato No.", ContratoPlanningLineSource."Contrato Task No.");
            ContratoTask.TestField("Bill-to Customer No.");
            BillToCustomerNo := ContratoTask."Bill-to Customer No.";
        end;
#if not CLEAN23
        IsHandled := false;
        OnCreateSalesInvoiceLinesOnBeforeGetCustomer(ContratoPlanningLineSource, Cust, IsHandled);
        if not IsHandled then
#endif
            Cust.Get(BillToCustomerNo);
    end;

    procedure DeleteSalesInvoiceBuffer()
    begin
        ClearAll();
        TempContratoPlanningLine.DeleteAll();
    end;
#if not CLEAN23

    procedure CreateSalesInvoiceContratoTask(var ContratoTask2: Record "Contrato Task"; PostingDate: Date; InvoicePerTask: Boolean; var NoOfInvoices: Integer; var OldContratoNo: Code[20]; var OldContratoTaskNo: Code[20]; LastContratoTask: Boolean)
    begin
        CreateSalesInvoiceContratoTask(ContratoTask2, PostingDate, 0D, InvoicePerTask, NoOfInvoices, OldContratoNo, OldContratoTaskNo, LastContratoTask);
    end;
#endif
    procedure CreateSalesInvoiceContratoTask(var ContratoTask2: Record "Contrato Task"; PostingDate: Date; DocumentDate: Date; InvoicePerTask: Boolean; var NoOfInvoices: Integer; var OldContratoNo: Code[20]; var OldContratoTaskNo: Code[20]; LastContratoTask: Boolean)
    var
        Cust: Record Customer;
        Contrato: Record Contrato;
        ContratoTask: Record "Contrato Task";
        ContratoPlanningLine: Record "Contrato Planning Line";
        ContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateSalesInvoiceContratoTask(
          ContratoTask2, PostingDate, InvoicePerTask, NoOfInvoices, OldContratoNo, OldContratoTaskNo, LastContratoTask, IsHandled);
        if IsHandled then
            exit;

        ClearAll();
        if not LastContratoTask then begin
            ContratoTask := ContratoTask2;
            if ContratoTask."Contrato No." = '' then
                exit;
            if ContratoTask."Contrato Task No." = '' then
                exit;
            ContratoTask.Find();
            if ContratoTask."Contrato Task Type" <> ContratoTask."Contrato Task Type"::Posting then
                exit;
            Contrato.Get(ContratoTask."Contrato No.");
        end;
        if LastContratoTask then begin
            if not TempContratoPlanningLine.Find('-') then
                exit;
            Contrato.Get(TempContratoPlanningLine."Contrato No.");
            ContratoTask.Get(TempContratoPlanningLine."Contrato No.", TempContratoPlanningLine."Contrato Task No.");
        end;

        OnCreateSalesInvoiceContratoTaskTestContrato(Contrato, ContratoPlanningLine, PostingDate);
        TestIfBillToCustomerExistOnContratoOrContratoTask(Contrato, ContratoTask2);
        if Contrato.Blocked = Contrato.Blocked::All then
            Contrato.TestBlocked();
        if Contrato."Currency Code" = '' then
            ContratoInvCurrency := IsContratoInvCurrencyDependingOnBillingMethod(Contrato, ContratoTask2);
        Cust.Get(ReturnBillToCustomerNoDependingOnTaskBillingMethod(Contrato, ContratoTask2));

        if CreateNewInvoice(ContratoTask, InvoicePerTask, OldContratoNo, OldContratoTaskNo, LastContratoTask) then begin
            Contrato.Get(TempContratoPlanningLine."Contrato No.");
            Cust.Get(ReturnBillToCustomerNoDependingOnTaskBillingMethod(Contrato, ContratoTask2));
            SalesHeader2."Document Type" := SalesHeader2."Document Type"::Invoice;
            if not SalesInvoiceExistForMultipleCustomerBillingMethod(Contrato) then begin
                CreateSalesHeader(Contrato, PostingDate, DocumentDate, TempContratoPlanningLine);
                NoOfInvoices := NoOfInvoices + 1;
            end;
            OnCreateSalesInvoiceContratoTaskOnBeforeTempContratoPlanningLineFind(ContratoTask, SalesHeader, InvoicePerTask, TempContratoPlanningLine);
            if TempContratoPlanningLine.Find('-') then
                repeat
                    Contrato.Get(TempContratoPlanningLine."Contrato No.");
                    ContratoInvCurrency := (Contrato."Currency Code" = '') and IsContratoInvCurrencyDependingOnBillingMethod(Contrato, TempContratoPlanningLine);
                    ContratoPlanningLine := TempContratoPlanningLine;
                    ContratoPlanningLine.Find();
                    if ContratoPlanningLine.Type in [ContratoPlanningLine.Type::Resource,
                                                ContratoPlanningLine.Type::Item,
                                                ContratoPlanningLine.Type::"G/L Account"]
                    then
                        ContratoPlanningLine.TestField("No.");
                    TestExchangeRate(ContratoPlanningLine, PostingDate);

                    OnCreateSalesInvoiceContratoTaskOnBeforeCreateSalesLine(ContratoPlanningLine, SalesHeader, SalesHeader2, NoOfSalesLinesCreated);
                    CreateSalesLine(ContratoPlanningLine);

                    ContratoPlanningLineInvoice."Contrato No." := ContratoPlanningLine."Contrato No.";
                    ContratoPlanningLineInvoice."Contrato Task No." := ContratoPlanningLine."Contrato Task No.";
                    ContratoPlanningLineInvoice."Contrato Planning Line No." := ContratoPlanningLine."Line No.";
                    if SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice then
                        ContratoPlanningLineInvoice."Document Type" := ContratoPlanningLineInvoice."Document Type"::Invoice;
                    if SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo" then
                        ContratoPlanningLineInvoice."Document Type" := ContratoPlanningLineInvoice."Document Type"::"Credit Memo";
                    ContratoPlanningLineInvoice."Document No." := SalesHeader."No.";
                    ContratoPlanningLineInvoice."Line No." := SalesLine."Line No.";
                    ContratoPlanningLineInvoice."Quantity Transferred" := ContratoPlanningLine."Qty. to Transfer to Invoice";
                    ContratoPlanningLineInvoice."Transferred Date" := PostingDate;
                    OnCreateSalesInvoiceContratoTaskOnBeforeContratoPlanningLineInvoiceInsert(ContratoPlanningLineInvoice);
                    ContratoPlanningLineInvoice.Insert();

                    ContratoPlanningLine.UpdateQtyToTransfer();
                    ContratoPlanningLine.Modify();
                until TempContratoPlanningLine.Next() = 0;
            TempContratoPlanningLine.DeleteAll();
        end;

        OnCreateSalesInvoiceContratoTaskOnAfterLinesCreated(SalesHeader, Contrato, InvoicePerTask, LastContratoTask);

        if LastContratoTask then begin
            if NoOfSalesLinesCreated = 0 then
                Error(Text002, ContratoPlanningLine.TableCaption(), ContratoPlanningLine.FieldCaption("Qty. to Transfer to Invoice"));
            exit;
        end;

        ContratoPlanningLine.Reset();
        ContratoPlanningLine.SetCurrentKey("Contrato No.", "Contrato Task No.");
        ContratoPlanningLine.SetRange("Contrato No.", ContratoTask2."Contrato No.");
        ContratoPlanningLine.SetRange("Contrato Task No.", ContratoTask2."Contrato Task No.");
        ContratoPlanningLine.SetFilter("Planning Date", ContratoTask2.GetFilter("Planning Date Filter"));
        OnCreateSalesInvoiceContratoTaskOnAfterContratoPlanningLineSetFilters(ContratoPlanningLine, ContratoTask2);
        if ContratoPlanningLine.Find('-') then
            repeat
                if TransferLine(ContratoPlanningLine) then begin
                    TempContratoPlanningLine := ContratoPlanningLine;
                    TempContratoPlanningLine.Insert();

                    if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"Multiple customers" then begin
                        TempContratoPlanningLine2 := ContratoPlanningLine;
                        TempContratoPlanningLine2.Insert();
                    end;
                end;
            until ContratoPlanningLine.Next() = 0;
    end;

    local procedure CreateNewInvoice(var ContratoTask: Record "Contrato Task"; InvoicePerTask: Boolean; var OldContratoNo: Code[20]; var OldContratoTaskNo: Code[20]; LastContratoTask: Boolean): Boolean
    var
        NewInvoice: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateNewInvoice(ContratoTask, InvoicePerTask, OldContratoNo, OldContratoTaskNo, LastContratoTask, NewInvoice, IsHandled);
        if IsHandled then
            exit(NewInvoice);

        if LastContratoTask then
            NewInvoice := true
        else begin
            if OldContratoNo <> '' then begin
                if InvoicePerTask then
                    if (OldContratoNo <> ContratoTask."Contrato No.") or (OldContratoTaskNo <> ContratoTask."Contrato Task No.") then
                        NewInvoice := true;
                if not InvoicePerTask then
                    if OldContratoNo <> ContratoTask."Contrato No." then
                        NewInvoice := true;
            end;
            OldContratoNo := ContratoTask."Contrato No.";
            OldContratoTaskNo := ContratoTask."Contrato Task No.";
        end;
        if not TempContratoPlanningLine.Find('-') then
            NewInvoice := false;
        exit(NewInvoice);
    end;

    local procedure CreateSalesHeader(Contrato: Record Contrato; PostingDate: Date; DocumentDate: Date; ContratoPlanningLine: Record "Contrato Planning Line")
    var
        ContratoTask: Record "Contrato Task";
        SalesSetup: Record "Sales & Receivables Setup";
        IsHandled: Boolean;
    begin
        OnBeforeCreateSalesHeader(Contrato, PostingDate, SalesHeader2, ContratoPlanningLine);

        SalesSetup.Get();
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader2."Document Type";
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice then
            SalesSetup.TestField("Invoice Nos.");
        if SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo" then
            SalesSetup.TestField("Credit Memo Nos.");
        SalesHeader."Posting Date" := PostingDate;
        SalesHeader."Document Date" := DocumentDate;
        OnBeforeInsertSalesHeader(SalesHeader, Contrato, ContratoPlanningLine);
        SalesHeader.Insert(true);

        IsHandled := false;
        OnCreateSalesHeaderOnBeforeCheckBillToCustomerNo(SalesHeader, Contrato, ContratoPlanningLine, IsHandled);

        if not IsHandled then begin
            SalesHeader.SetHideValidationDialog(true);
            SalesHeader.Validate("Sell-to Customer No.", GetCustomerNo(Contrato, ContratoPlanningLine, true));
            SalesHeader.Validate("Bill-to Customer No.", GetCustomerNo(Contrato, ContratoPlanningLine, false));
        end;

        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then begin
            if Contrato."Payment Method Code" <> '' then
                SalesHeader.Validate("Payment Method Code", Contrato."Payment Method Code");
            if Contrato."Payment Terms Code" <> '' then
                SalesHeader.Validate("Payment Terms Code", Contrato."Payment Terms Code");
            if Contrato."External Document No." <> '' then
                SalesHeader.Validate("External Document No.", Contrato."External Document No.");
        end else begin
            ContratoTask.Get(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.");
            if ContratoTask."Payment Method Code" <> '' then
                SalesHeader.Validate("Payment Method Code", ContratoTask."Payment Method Code");
            if ContratoTask."Payment Terms Code" <> '' then
                SalesHeader.Validate("Payment Terms Code", ContratoTask."Payment Terms Code");
            if ContratoTask."External Document No." <> '' then
                SalesHeader.Validate("External Document No.", ContratoTask."External Document No.");
        end;

        if Contrato."Currency Code" <> '' then
            SalesHeader.Validate("Currency Code", Contrato."Currency Code")
        else
            SalesHeader.Validate("Currency Code", ReturnContratoDataDependingOnTaskBillingMethod(Contrato, ContratoPlanningLine, 'Invoice Currency Code'));

        if PostingDate <> 0D then
            SalesHeader.Validate("Posting Date", PostingDate);
        if DocumentDate <> 0D then
            SalesHeader.Validate("Document Date", DocumentDate);

        SalesHeader."Your Reference" := ReturnContratoDataDependingOnTaskBillingMethod(Contrato, ContratoPlanningLine, 'Your Reference');

        if SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice then
            SalesHeader.SetDefaultPaymentServices();

        IsHandled := false;
        OnCreateSalesHeaderOnBeforeUpdateSalesHeader(SalesHeader, Contrato, IsHandled, ContratoPlanningLine);
        if not IsHandled then
            if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
                UpdateSalesHeader(SalesHeader, Contrato)
            else
                UpdateSalesHeader(SalesHeader, ContratoPlanningLine);
        OnBeforeModifySalesHeader(SalesHeader, Contrato, ContratoPlanningLine);
        SalesHeader.Modify(true);
    end;

    local procedure SalesInvoiceExistForMultipleCustomerBillingMethod(Contrato: Record Contrato): Boolean
    var
        ContratoTask: Record "Contrato Task";
        ContratoTask2: Record "Contrato Task";
        ContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice";
        TempContratoPlanningLine3: Record "Contrato Planning Line" temporary;
        SelectionFilterMgt: Codeunit SelectionFilterManagement;
        RecRef: RecordRef;
        ContratoTaskFilter: Text;
    begin
        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
            exit;

        TempContratoPlanningLine3.Copy(TempContratoPlanningLine2, true);
        TempContratoPlanningLine3.Reset();
        TempContratoPlanningLine3.SetFilter("Contrato Contract Entry No.", '<>%1', TempContratoPlanningLine."Contrato Contract Entry No.");
        RecRef.GetTable(TempContratoPlanningLine3);
        ContratoTaskFilter := SelectionFilterMgt.GetSelectionFilter(RecRef, TempContratoPlanningLine3.FieldNo("Contrato Task No."));
        if ContratoTaskFilter = '' then
            exit;

        if ContratoTask.Get(TempContratoPlanningLine."Contrato No.", TempContratoPlanningLine."Contrato Task No.") then begin
            ContratoTask2.SetRange("Contrato No.", Contrato."No.");
            ContratoTask2.SetFilter("Contrato Task No.", ContratoTaskFilter);
            ContratoTask2.SetRange("Sell-to Customer No.", ContratoTask."Sell-to Customer No.");
            ContratoTask2.SetRange("Bill-to Customer No.", ContratoTask."Bill-to Customer No.");
            ContratoTask2.SetRange("Invoice Currency Code", ContratoTask."Invoice Currency Code");
            if ContratoTask2.FindFirst() then begin
                ContratoPlanningLineInvoice.SetRange("Contrato No.", Contrato."No.");
                ContratoPlanningLineInvoice.SetRange("Contrato Task No.", ContratoTask2."Contrato Task No.");
                ContratoPlanningLineInvoice.SetRange("Document Type", ContratoPlanningLineInvoice."Document Type"::Invoice);
                if ContratoPlanningLineInvoice.FindFirst() then begin
                    SalesHeader.Get(SalesHeader."Document Type"::Invoice, ContratoPlanningLineInvoice."Document No.");
                    exit(true);
                end;
            end;
        end;
    end;

    local procedure GetCustomerNo(Contrato: Record Contrato; ContratoPlanningLine: Record "Contrato Planning Line"; SellToCustomerNo: Boolean) CustomerNo: Code[20]
    var
        ContratoTask: Record "Contrato Task";
    begin
        OnBeforeGetCustomerNo(Contrato, ContratoPlanningLine, SellToCustomerNo, CustomerNo);
        if CustomerNo <> '' then
            exit(CustomerNo);

        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
            if SellToCustomerNo then
                exit(Contrato."Sell-to Customer No.")
            else
                exit(Contrato."Bill-to Customer No.");

        ContratoTask.Get(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.");
        if SellToCustomerNo then
            exit(ContratoTask."Sell-to Customer No.")
        else
            exit(ContratoTask."Bill-to Customer No.");
    end;

    local procedure CreateSalesLine(var ContratoPlanningLine: Record "Contrato Planning Line")
    var
        Contrato: Record Contrato;
        Factor: Integer;
        IsHandled: Boolean;
        ShouldUpdateCurrencyFactor: Boolean;
    begin
        OnBeforeCreateSalesLine(ContratoPlanningLine, SalesHeader, SalesHeader2, ContratoInvCurrency);

        Factor := 1;
        if SalesHeader2."Document Type" = SalesHeader2."Document Type"::"Credit Memo" then
            Factor := -1;
        TestTransferred(ContratoPlanningLine);
        ContratoPlanningLine.TestField("Planning Date");
        Contrato.Get(ContratoPlanningLine."Contrato No.");
        Clear(SalesLine);
        SalesLine."Document Type" := SalesHeader2."Document Type";
        SalesLine."Document No." := SalesHeader."No.";

        ShouldUpdateCurrencyFactor := (not ContratoInvCurrency) and (ContratoPlanningLine.Type <> ContratoPlanningLine.Type::Text);
        OnCreateSalesLineOnAfterCalcShouldUpdateCurrencyFactor(ContratoPlanningLine, Contrato, SalesHeader, SalesHeader2, ContratoInvCurrency, ShouldUpdateCurrencyFactor);
        if ShouldUpdateCurrencyFactor then begin
            SalesHeader.TestField("Currency Code", ContratoPlanningLine."Currency Code");
            if (Contrato."Currency Code" <> '') and (ContratoPlanningLine."Currency Factor" <> SalesHeader."Currency Factor") then
                if Confirm(Text011) then begin
                    ContratoPlanningLine.Validate("Currency Factor", SalesHeader."Currency Factor");
                    ContratoPlanningLine.Modify();
                end else
                    Error(Text001);
            SalesHeader.TestField("Currency Code", Contrato."Currency Code");
        end;
        if ContratoPlanningLine.Type = ContratoPlanningLine.Type::Text then
            SalesLine.Validate(Type, SalesLine.Type::" ");
        if ContratoPlanningLine.Type = ContratoPlanningLine.Type::"G/L Account" then
            SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        if ContratoPlanningLine.Type = ContratoPlanningLine.Type::Item then
            SalesLine.Validate(Type, SalesLine.Type::Item);
        if ContratoPlanningLine.Type = ContratoPlanningLine.Type::Resource then
            SalesLine.Validate(Type, SalesLine.Type::Resource);


        IsHandled := false;
        OnCreateSalesLineOnBeforeValidateSalesLineNo(ContratoPlanningLine, SalesLine, IsHandled);
        if not IsHandled then
            SalesLine.Validate("No.", ContratoPlanningLine."No.");
        SalesLine.Validate("Gen. Prod. Posting Group", ContratoPlanningLine."Gen. Prod. Posting Group");
        SalesLine.Validate("Location Code", ContratoPlanningLine."Location Code");
        SalesLine.Validate("Work Type Code", ContratoPlanningLine."Work Type Code");
        SalesLine.Validate("Variant Code", ContratoPlanningLine."Variant Code");

        if SalesLine.Type <> SalesLine.Type::" " then begin
            SalesLine.Validate("Unit of Measure Code", ContratoPlanningLine."Unit of Measure Code");
            SalesLine.Validate(Quantity, Factor * ContratoPlanningLine."Qty. to Transfer to Invoice");
            if ContratoPlanningLine."Bin Code" <> '' then
                SalesLine."Bin Code" := ContratoPlanningLine."Bin Code";
            if ContratoInvCurrency then begin
                OnCreateSalesLineOnBeforeValidateCurrencyCode(IsHandled, SalesLine, ContratoPlanningLine);
                if not IsHandled then begin
                    Currency.Get(SalesLine."Currency Code");
                    SalesLine.Validate("Unit Price",
                    Round(ContratoPlanningLine."Unit Price" * SalesHeader."Currency Factor",
                        Currency."Unit-Amount Rounding Precision"));
                end;
            end else
                SalesLine.Validate("Unit Price", ContratoPlanningLine."Unit Price");
            SalesLine.Validate("Unit Cost (LCY)", ContratoPlanningLine."Unit Cost (LCY)");
            SalesLine.Validate("Line Discount %", ContratoPlanningLine."Line Discount %");
            SalesLine."Inv. Discount Amount" := 0;
            SalesLine."Inv. Disc. Amount to Invoice" := 0;
            SalesLine.UpdateAmounts();
        end;

        IsHandled := false;
        OnCreateSalesLineOnBeforeCheckPricesIncludingVATAndSetContratoInformation(SalesLine, ContratoPlanningLine, IsHandled);
        if not IsHandled then begin
            if not SalesHeader."Prices Including VAT" then
                SalesLine.Validate("Job Contract Entry No.", ContratoPlanningLine."Contrato Contract Entry No.");
            SalesLine."Job No." := ContratoPlanningLine."Contrato No.";
            SalesLine."Job Task No." := ContratoPlanningLine."Contrato Task No.";
        end;
        SalesLine.Description := ContratoPlanningLine.Description;
        SalesLine."Description 2" := ContratoPlanningLine."Description 2";
        SalesLine."Line No." := GetNextLineNo(SalesLine);
        OnBeforeInsertSalesLine(SalesLine, SalesHeader, Contrato, ContratoPlanningLine, ContratoInvCurrency);
        SalesLine.Insert(true);

        if SalesLine.Type <> SalesLine.Type::" " then begin
            NoOfSalesLinesCreated += 1;
            CalculateInvoiceDiscount(SalesLine, SalesHeader);
        end;

        if SalesHeader."Prices Including VAT" and (SalesLine.Type <> SalesLine.Type::" ") then begin
            Currency.Initialize(SalesLine."Currency Code");
            SalesLine."Unit Price" :=
              Round(
                SalesLine."Unit Price" * (1 + (SalesLine."VAT %" / 100)),
                Currency."Unit-Amount Rounding Precision");
            if SalesLine.Quantity <> 0 then begin
                SalesLine."Line Discount Amount" :=
                  Round(
                    SalesLine.Quantity * SalesLine."Unit Price" * SalesLine."Line Discount %" / 100,
                    Currency."Amount Rounding Precision");
                SalesLine.Validate("Inv. Discount Amount",
                  Round(
                    SalesLine."Inv. Discount Amount" * (1 + (SalesLine."VAT %" / 100)),
                    Currency."Amount Rounding Precision"));
            end;
            SalesLine.Validate("Job Contract Entry No.", ContratoPlanningLine."Contrato Contract Entry No.");
            OnBeforeModifySalesLine(SalesLine, SalesHeader, Contrato, ContratoPlanningLine);
            SalesLine.Modify();
            OnCreateSalesLineOnAfterSalesLineModify(SalesLine, SalesHeader, Contrato, ContratoPlanningLine);
            ContratoPlanningLine."VAT Unit Price" := SalesLine."Unit Price";
            ContratoPlanningLine."VAT Line Discount Amount" := SalesLine."Line Discount Amount";
            ContratoPlanningLine."VAT Line Amount" := SalesLine."Line Amount";
            ContratoPlanningLine."VAT %" := SalesLine."VAT %";
        end;
        if SalesLine."Job Task No." <> '' then
            UpdateSalesLineDimension(SalesLine, ContratoPlanningLine);

        IsHandled := false;
        OnCreateSalesLineOnBeforeSalesCheckIfAnyExtText(ContratoPlanningLine, SalesLine, IsHandled);
        if not IsHandled then
            if TransferExtendedText.SalesCheckIfAnyExtText(SalesLine, false) then
                TransferExtendedText.InsertSalesExtText(SalesLine);

        OnAfterCreateSalesLine(SalesLine, SalesHeader, Contrato, ContratoPlanningLine);
    end;

    local procedure CalculateInvoiceDiscount(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    var
        TotalSalesHeader: Record "Sales Header";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        TotalSalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        TotalSalesHeader.CalcFields("Recalculate Invoice Disc.");

        SalesReceivablesSetup.Get();
        if SalesReceivablesSetup."Calc. Inv. Discount" and
           (SalesLine."Document No." <> '') and
           (TotalSalesHeader."Customer Posting Group" <> '') and
           TotalSalesHeader."Recalculate Invoice Disc."
        then
            CODEUNIT.Run(CODEUNIT::"Sales-Calc. Discount", SalesLine);
    end;

    local procedure TransferLine(var ContratoPlanningLine: Record "Contrato Planning Line"): Boolean
    var
        IsHandled, Result : Boolean;
    begin
        IsHandled := false;
        OnBeforeTransferLine(ContratoPlanningLine, IsHandled, Result);
        if IsHandled then
            exit(Result);

        if not ContratoPlanningLine."Contract Line" then
            exit(false);
        if ContratoPlanningLine.Type = ContratoPlanningLine.Type::Text then
            exit(true);
        exit(ContratoPlanningLine."Qty. to Transfer to Invoice" <> 0);
    end;

    local procedure GetNextLineNo(SalesLine: Record "Sales Line"): Integer
    var
        NextLineNo: Integer;
    begin
        SalesLine.SetRange("Document Type", SalesLine."Document Type");
        SalesLine.SetRange("Document No.", SalesLine."Document No.");
        NextLineNo := 10000;
        if SalesLine.FindLast() then
            NextLineNo := SalesLine."Line No." + 10000;
        exit(NextLineNo);
    end;

    local procedure TestTransferred(ContratoPlanningLine: Record "Contrato Planning Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestTransferred(ContratoPlanningLine, SalesHeader2, IsHandled);
        if IsHandled then
            exit;

        ContratoPlanningLine.CalcFields("Qty. Transferred to Invoice");
        if ContratoPlanningLine.Quantity > 0 then begin
            if (ContratoPlanningLine."Qty. to Transfer to Invoice" > 0) and (ContratoPlanningLine."Qty. to Transfer to Invoice" > (ContratoPlanningLine.Quantity - ContratoPlanningLine."Qty. Transferred to Invoice")) or
                (ContratoPlanningLine."Qty. to Transfer to Invoice" < 0)
            then
                Error(Text003, ContratoPlanningLine.FieldCaption("Qty. to Transfer to Invoice"), 0, ContratoPlanningLine.Quantity - ContratoPlanningLine."Qty. Transferred to Invoice");
        end else
            if (ContratoPlanningLine."Qty. to Transfer to Invoice" > 0) or
                (ContratoPlanningLine."Qty. to Transfer to Invoice" < 0) and (ContratoPlanningLine."Qty. to Transfer to Invoice" < (ContratoPlanningLine.Quantity - ContratoPlanningLine."Qty. Transferred to Invoice"))
            then
                Error(Text003, ContratoPlanningLine.FieldCaption("Qty. to Transfer to Invoice"), ContratoPlanningLine.Quantity - ContratoPlanningLine."Qty. Transferred to Invoice", 0);
    end;

    procedure DeleteSalesLine(SalesLine: Record "Sales Line")
    var
        ContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice";
        ContratoPlanningLine: Record "Contrato Planning Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeDeleteSalesLine(SalesLine, IsHandled);
        if IsHandled then
            exit;

        case SalesLine."Document Type" of
            SalesLine."Document Type"::Invoice:
                ContratoPlanningLineInvoice.SetRange("Document Type", ContratoPlanningLineInvoice."Document Type"::Invoice);
            SalesLine."Document Type"::"Credit Memo":
                ContratoPlanningLineInvoice.SetRange("Document Type", ContratoPlanningLineInvoice."Document Type"::"Credit Memo");
        end;
        ContratoPlanningLineInvoice.SetRange("Document No.", SalesLine."Document No.");
        ContratoPlanningLineInvoice.SetRange("Line No.", SalesLine."Line No.");
        if ContratoPlanningLineInvoice.FindSet() then
            repeat
                OnDeleteSalesLineOnBeforeGetContratoPlanningLine(ContratoPlanningLineInvoice);
                ContratoPlanningLine.Get(ContratoPlanningLineInvoice."Contrato No.", ContratoPlanningLineInvoice."Contrato Task No.", ContratoPlanningLineInvoice."Contrato Planning Line No.");
                ContratoPlanningLineInvoice.Delete();
                ContratoPlanningLine.UpdateQtyToTransfer();
                OnDeleteSalesLineOnBeforeContratoPlanningLineModify(ContratoPlanningLine);
                ContratoPlanningLine.Modify();
            until ContratoPlanningLineInvoice.Next() = 0;
    end;

    procedure FindInvoices(var TempContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice" temporary; ContratoNo: Code[20]; ContratoTaskNo: Code[20]; ContratoPlanningLineNo: Integer; DetailLevel: Option All,"Per Contrato","Per Contrato Task","Per Contrato Planning Line")
    var
        ContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice";
        RecordFound: Boolean;
        IsHandled: Boolean;
    begin
        OnBeforeFindInvoices(TempContratoPlanningLineInvoice, ContratoNo, ContratoTaskNo, ContratoPlanningLineNo, DetailLevel, IsHandled);
        if IsHandled then
            exit;

        case DetailLevel of
            DetailLevel::All:
                begin
                    if ContratoPlanningLineInvoice.FindSet() then
                        TempContratoPlanningLineInvoice := ContratoPlanningLineInvoice;
                    exit;
                end;
            DetailLevel::"Per Contrato":
                ContratoPlanningLineInvoice.SetRange("Contrato No.", ContratoNo);
            DetailLevel::"Per Contrato Task":
                begin
                    ContratoPlanningLineInvoice.SetRange("Contrato No.", ContratoNo);
                    ContratoPlanningLineInvoice.SetRange("Contrato Task No.", ContratoTaskNo);
                end;
            DetailLevel::"Per Contrato Planning Line":
                begin
                    ContratoPlanningLineInvoice.SetRange("Contrato No.", ContratoNo);
                    ContratoPlanningLineInvoice.SetRange("Contrato Task No.", ContratoTaskNo);
                    ContratoPlanningLineInvoice.SetRange("Contrato Planning Line No.", ContratoPlanningLineNo);
                end;
        end;

        TempContratoPlanningLineInvoice.DeleteAll();
        if ContratoPlanningLineInvoice.FindSet() then
            repeat
                RecordFound := false;
                case DetailLevel of
                    DetailLevel::"Per Contrato":
                        if TempContratoPlanningLineInvoice.Get(
                             ContratoNo, '', 0, ContratoPlanningLineInvoice."Document Type", ContratoPlanningLineInvoice."Document No.", 0)
                        then
                            RecordFound := true;
                    DetailLevel::"Per Contrato Task":
                        if TempContratoPlanningLineInvoice.Get(
                             ContratoNo, ContratoTaskNo, 0, ContratoPlanningLineInvoice."Document Type", ContratoPlanningLineInvoice."Document No.", 0)
                        then
                            RecordFound := true;
                    DetailLevel::"Per Contrato Planning Line":
                        if TempContratoPlanningLineInvoice.Get(
                             ContratoNo, ContratoTaskNo, ContratoPlanningLineNo, ContratoPlanningLineInvoice."Document Type", ContratoPlanningLineInvoice."Document No.", 0)
                        then
                            RecordFound := true;
                end;

                if RecordFound then begin
                    TempContratoPlanningLineInvoice."Quantity Transferred" += ContratoPlanningLineInvoice."Quantity Transferred";
                    TempContratoPlanningLineInvoice."Invoiced Amount (LCY)" += ContratoPlanningLineInvoice."Invoiced Amount (LCY)";
                    TempContratoPlanningLineInvoice."Invoiced Cost Amount (LCY)" += ContratoPlanningLineInvoice."Invoiced Cost Amount (LCY)";
                    OnFindInvoicesOnBeforeTempContratoPlanningLineInvoiceModify(TempContratoPlanningLineInvoice, ContratoPlanningLineInvoice);
                    TempContratoPlanningLineInvoice.Modify();
                end else begin
                    case DetailLevel of
                        DetailLevel::"Per Contrato":
                            TempContratoPlanningLineInvoice."Contrato No." := ContratoNo;
                        DetailLevel::"Per Contrato Task":
                            begin
                                TempContratoPlanningLineInvoice."Contrato No." := ContratoNo;
                                TempContratoPlanningLineInvoice."Contrato Task No." := ContratoTaskNo;
                            end;
                        DetailLevel::"Per Contrato Planning Line":
                            begin
                                TempContratoPlanningLineInvoice."Contrato No." := ContratoNo;
                                TempContratoPlanningLineInvoice."Contrato Task No." := ContratoTaskNo;
                                TempContratoPlanningLineInvoice."Contrato Planning Line No." := ContratoPlanningLineNo;
                            end;
                    end;
                    TempContratoPlanningLineInvoice."Document Type" := ContratoPlanningLineInvoice."Document Type";
                    TempContratoPlanningLineInvoice."Document No." := ContratoPlanningLineInvoice."Document No.";
                    TempContratoPlanningLineInvoice."Quantity Transferred" := ContratoPlanningLineInvoice."Quantity Transferred";
                    TempContratoPlanningLineInvoice."Invoiced Amount (LCY)" := ContratoPlanningLineInvoice."Invoiced Amount (LCY)";
                    TempContratoPlanningLineInvoice."Invoiced Cost Amount (LCY)" := ContratoPlanningLineInvoice."Invoiced Cost Amount (LCY)";
                    TempContratoPlanningLineInvoice."Invoiced Date" := ContratoPlanningLineInvoice."Invoiced Date";
                    TempContratoPlanningLineInvoice."Transferred Date" := ContratoPlanningLineInvoice."Transferred Date";
                    OnFindInvoicesOnBeforeTempContratoPlanningLineInvoiceInsert(TempContratoPlanningLineInvoice, ContratoPlanningLineInvoice);
                    TempContratoPlanningLineInvoice.Insert();
                end;
            until ContratoPlanningLineInvoice.Next() = 0;
    end;

    procedure GetContratoPlanningLineInvoices(ContratoPlanningLine: Record "Contrato Planning Line")
    var
        ContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice";
    begin
        OnBeforeGetContratoPlanningLineInvoices(ContratoPlanningLine);

        ClearAll();
        if ContratoPlanningLine."Line No." = 0 then
            exit;

        ContratoPlanningLine.TestField("Contrato No.");
        ContratoPlanningLine.TestField("Contrato Task No.");

        ContratoPlanningLineInvoice.SetRange("Contrato No.", ContratoPlanningLine."Contrato No.");
        ContratoPlanningLineInvoice.SetRange("Contrato Task No.", ContratoPlanningLine."Contrato Task No.");
        ContratoPlanningLineInvoice.SetRange("Contrato Planning Line No.", ContratoPlanningLine."Line No.");
        if ContratoPlanningLineInvoice.Count = 1 then begin
            ContratoPlanningLineInvoice.FindFirst();
            OpenSalesInvoice(ContratoPlanningLineInvoice);
        end else
            PAGE.RunModal(PAGE::"Contrato Invoices", ContratoPlanningLineInvoice);
    end;

    procedure OpenSalesInvoice(ContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice")
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOpenSalesInvoice(ContratoPlanningLineInvoice, IsHandled);
        if IsHandled then
            exit;

        case ContratoPlanningLineInvoice."Document Type" of
            ContratoPlanningLineInvoice."Document Type"::Invoice:
                begin
                    SalesHeader.Get(SalesHeader."Document Type"::Invoice, ContratoPlanningLineInvoice."Document No.");
                    PAGE.RunModal(PAGE::"Sales Invoice", SalesHeader);
                end;
            ContratoPlanningLineInvoice."Document Type"::"Credit Memo":
                begin
                    SalesHeader.Get(SalesHeader."Document Type"::"Credit Memo", ContratoPlanningLineInvoice."Document No.");
                    PAGE.RunModal(PAGE::"Sales Credit Memo", SalesHeader);
                end;
            ContratoPlanningLineInvoice."Document Type"::"Posted Invoice":
                begin
                    if not SalesInvHeader.Get(ContratoPlanningLineInvoice."Document No.") then
                        Error(Text012, SalesInvHeader.TableCaption(), ContratoPlanningLineInvoice."Document No.");
                    PAGE.RunModal(PAGE::"Posted Sales Invoice", SalesInvHeader);
                end;
            ContratoPlanningLineInvoice."Document Type"::"Posted Credit Memo":
                begin
                    if not SalesCrMemoHeader.Get(ContratoPlanningLineInvoice."Document No.") then
                        Error(Text012, SalesCrMemoHeader.TableCaption(), ContratoPlanningLineInvoice."Document No.");
                    PAGE.RunModal(PAGE::"Posted Sales Credit Memo", SalesCrMemoHeader);
                end;
        end;

        OnAfterOpenSalesInvoice(ContratoPlanningLineInvoice);
    end;

    local procedure UpdateSalesHeader(var SalesHeader: Record "Sales Header"; Contrato: Record Contrato)
    var
        FormatAddress: Codeunit "Format Address";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateSalesHeader(SalesHeader, Contrato, IsHandled);
        if not IsHandled then begin
            SalesHeader."Bill-to Contact No." := Contrato."Bill-to Contact No.";
            SalesHeader."Bill-to Contact" := Contrato."Bill-to Contact";
            SalesHeader."Bill-to Name" := Contrato."Bill-to Name";
            SalesHeader."Bill-to Name 2" := Contrato."Bill-to Name 2";
            SalesHeader."Bill-to Address" := Contrato."Bill-to Address";
            SalesHeader."Bill-to Address 2" := Contrato."Bill-to Address 2";
            SalesHeader."Bill-to City" := Contrato."Bill-to City";
            SalesHeader."Bill-to Post Code" := Contrato."Bill-to Post Code";
            SalesHeader."Bill-to Country/Region Code" := Contrato."Bill-to Country/Region Code";

            SalesHeader."Sell-to Contact No." := Contrato."Sell-to Contact No.";
            SalesHeader."Sell-to Contact" := Contrato."Sell-to Contact";
            SalesHeader."Sell-to Customer Name" := Contrato."Sell-to Customer Name";
            SalesHeader."Sell-to Customer Name 2" := Contrato."Sell-to Customer Name 2";
            SalesHeader."Sell-to Address" := Contrato."Sell-to Address";
            SalesHeader."Sell-to Address 2" := Contrato."Sell-to Address 2";
            SalesHeader."Sell-to City" := Contrato."Sell-to City";
            SalesHeader."Sell-to Post Code" := Contrato."Sell-to Post Code";
            SalesHeader."Sell-to Country/Region Code" := Contrato."Sell-to Country/Region Code";

            if Contrato."Ship-to Code" <> '' then
                SalesHeader.Validate("Ship-to Code", Contrato."Ship-to Code")
            else
                if SalesHeader."Ship-to Code" = '' then begin
                    SalesHeader."Ship-to Contact" := Contrato."Ship-to Contact";
                    SalesHeader."Ship-to Name" := Contrato."Ship-to Name";
                    SalesHeader."Ship-to Address" := Contrato."Ship-to Address";
                    SalesHeader."Ship-to Address 2" := Contrato."Ship-to Address 2";
                    SalesHeader."Ship-to City" := Contrato."Ship-to City";
                    SalesHeader."Ship-to Post Code" := Contrato."Ship-to Post Code";
                    SalesHeader."Ship-to Country/Region Code" := Contrato."Ship-to Country/Region Code";
                    if FormatAddress.UseCounty(SalesHeader."Ship-to Country/Region Code") then
                        SalesHeader."Ship-to County" := Contrato."Ship-to County";
                end;

            if FormatAddress.UseCounty(SalesHeader."Bill-to Country/Region Code") then
                SalesHeader."Bill-to County" := Contrato."Bill-to County";
            if FormatAddress.UseCounty(SalesHeader."Sell-to Country/Region Code") then
                SalesHeader."Sell-to County" := Contrato."Sell-to County";
        end;
        OnAfterUpdateSalesHeader(SalesHeader, Contrato);
    end;

    local procedure UpdateSalesHeader(var SalesHeader: Record "Sales Header"; ContratoPlanningLine: Record "Contrato Planning Line")
    var
        ContratoTask: Record "Contrato Task";
        FormatAddress: Codeunit "Format Address";
    begin
        ContratoTask.Get(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.");
        SalesHeader."Bill-to Contact No." := ContratoTask."Bill-to Contact No.";
        SalesHeader."Bill-to Contact" := ContratoTask."Bill-to Contact";
        SalesHeader."Bill-to Name" := ContratoTask."Bill-to Name";
        SalesHeader."Bill-to Name 2" := ContratoTask."Bill-to Name 2";
        SalesHeader."Bill-to Address" := ContratoTask."Bill-to Address";
        SalesHeader."Bill-to Address 2" := ContratoTask."Bill-to Address 2";
        SalesHeader."Bill-to City" := ContratoTask."Bill-to City";
        SalesHeader."Bill-to Post Code" := ContratoTask."Bill-to Post Code";
        SalesHeader."Bill-to Country/Region Code" := ContratoTask."Bill-to Country/Region Code";

        SalesHeader."Sell-to Contact No." := ContratoTask."Sell-to Contact No.";
        SalesHeader."Sell-to Contact" := ContratoTask."Sell-to Contact";
        SalesHeader."Sell-to Customer Name" := ContratoTask."Sell-to Customer Name";
        SalesHeader."Sell-to Customer Name 2" := ContratoTask."Sell-to Customer Name 2";
        SalesHeader."Sell-to Address" := ContratoTask."Sell-to Address";
        SalesHeader."Sell-to Address 2" := ContratoTask."Sell-to Address 2";
        SalesHeader."Sell-to City" := ContratoTask."Sell-to City";
        SalesHeader."Sell-to Post Code" := ContratoTask."Sell-to Post Code";
        SalesHeader."Sell-to Country/Region Code" := ContratoTask."Sell-to Country/Region Code";

        if ContratoTask."Ship-to Code" <> '' then
            SalesHeader.Validate("Ship-to Code", ContratoTask."Ship-to Code")
        else
            if SalesHeader."Ship-to Code" = '' then begin
                SalesHeader."Ship-to Contact" := ContratoTask."Ship-to Contact";
                SalesHeader."Ship-to Name" := ContratoTask."Ship-to Name";
                SalesHeader."Ship-to Address" := ContratoTask."Ship-to Address";
                SalesHeader."Ship-to Address 2" := ContratoTask."Ship-to Address 2";
                SalesHeader."Ship-to City" := ContratoTask."Ship-to City";
                SalesHeader."Ship-to Post Code" := ContratoTask."Ship-to Post Code";
                SalesHeader."Ship-to Country/Region Code" := ContratoTask."Ship-to Country/Region Code";
                if FormatAddress.UseCounty(SalesHeader."Ship-to Country/Region Code") then
                    SalesHeader."Ship-to County" := ContratoTask."Ship-to County";
            end;

        if FormatAddress.UseCounty(SalesHeader."Bill-to Country/Region Code") then
            SalesHeader."Bill-to County" := ContratoTask."Bill-to County";
        if FormatAddress.UseCounty(SalesHeader."Sell-to Country/Region Code") then
            SalesHeader."Sell-to County" := ContratoTask."Sell-to County";
    end;

    local procedure TestSalesHeader(var SalesHeader: Record "Sales Header"; var Contrato: Record Contrato; ContratoPlanningLine: Record "Contrato Planning Line")
    var
        ContratoTask: Record "Contrato Task";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestSalesHeader(SalesHeader, Contrato, IsHandled, ContratoPlanningLine);
        if IsHandled then
            exit;

        Contrato.Get(ContratoPlanningLine."Contrato No.");
        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then begin
            SalesHeader.TestField("Bill-to Customer No.", Contrato."Bill-to Customer No.");
            SalesHeader.TestField("Sell-to Customer No.", Contrato."Sell-to Customer No.");
        end else begin
            ContratoTask.Get(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.");
            SalesHeader.TestField("Bill-to Customer No.", ContratoTask."Bill-to Customer No.");
            SalesHeader.TestField("Sell-to Customer No.", ContratoTask."Sell-to Customer No.");
        end;

        if Contrato."Currency Code" <> '' then
            SalesHeader.TestField("Currency Code", Contrato."Currency Code")
        else
            if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
                SalesHeader.TestField("Currency Code", Contrato."Invoice Currency Code")
            else
                SalesHeader.TestField("Currency Code", ContratoTask."Invoice Currency Code");
        OnAfterTestSalesHeader(SalesHeader, Contrato, ContratoPlanningLine);
    end;

    local procedure TestExchangeRate(var ContratoPlanningLine: Record "Contrato Planning Line"; PostingDate: Date)
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        OnBeforeTestExchangeRate(ContratoPlanningLine, PostingDate, UpdateExchangeRates, CurrencyExchangeRate);

        if ContratoPlanningLine."Currency Code" <> '' then
            if (CurrencyExchangeRate.ExchangeRate(PostingDate, ContratoPlanningLine."Currency Code") <> ContratoPlanningLine."Currency Factor")
            then begin
                if not UpdateExchangeRates then
                    UpdateExchangeRates := Confirm(Text010, true);

                if UpdateExchangeRates then begin
                    ContratoPlanningLine."Currency Date" := PostingDate;
                    ContratoPlanningLine."Document Date" := PostingDate;
                    ContratoPlanningLine.Validate("Currency Date");
                    ContratoPlanningLine."Last Date Modified" := Today;
                    ContratoPlanningLine."User ID" := CopyStr(UserId(), 1, MaxStrLen(ContratoPlanningLine."User ID"));
                    ContratoPlanningLine.Modify(true);
                end else
                    Error('');
            end;
    end;

    local procedure GetLedgEntryDimSetID(ContratoPlanningLine: Record "Contrato Planning Line"): Integer
    var
        ResLedgEntry: Record "Res. Ledger Entry";
        ItemLedgEntry: Record "Item Ledger Entry";
        GLEntry: Record "G/L Entry";
    begin
        if ContratoPlanningLine."Ledger Entry No." = 0 then
            exit(0);

        case ContratoPlanningLine."Ledger Entry Type" of
            ContratoPlanningLine."Ledger Entry Type"::Resource:
                begin
                    ResLedgEntry.Get(ContratoPlanningLine."Ledger Entry No.");
                    exit(ResLedgEntry."Dimension Set ID");
                end;
            ContratoPlanningLine."Ledger Entry Type"::Item:
                begin
                    ItemLedgEntry.Get(ContratoPlanningLine."Ledger Entry No.");
                    exit(ItemLedgEntry."Dimension Set ID");
                end;
            ContratoPlanningLine."Ledger Entry Type"::"G/L Account":
                begin
                    GLEntry.Get(ContratoPlanningLine."Ledger Entry No.");
                    exit(GLEntry."Dimension Set ID");
                end;
            else
                exit(0);
        end;
    end;

    local procedure GetContratoLedgEntryDimSetID(ContratoPlanningLine: Record "Contrato Planning Line"): Integer
    var
        ContratoLedgerEntry: Record "Contrato Ledger Entry";
    begin
        if ContratoPlanningLine."Contrato Ledger Entry No." = 0 then
            exit(0);

        if ContratoLedgerEntry.Get(ContratoPlanningLine."Contrato Ledger Entry No.") then
            exit(ContratoLedgerEntry."Dimension Set ID");

        exit(0);
    end;

    local procedure UpdateSalesLineDimension(var SalesLine: Record "Sales Line"; ContratoPlanningLine: Record "Contrato Planning Line")
    var
        SourceCodeSetup: Record "Source Code Setup";
        DimMgt: Codeunit DimensionManagement;
        DimSetIDArr: array[10] of Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateSalesLineDimension(SalesLine, ContratoPlanningLine, IsHandled);
        if not IsHandled then begin
            SourceCodeSetup.Get();
            DimSetIDArr[1] := SalesLine."Dimension Set ID";
            DimSetIDArr[2] :=
                DimMgt.CreateDimSetFromJobTaskDim(
                SalesLine."Job No.", SalesLine."Job Task No.", SalesLine."Shortcut Dimension 1 Code", SalesLine."Shortcut Dimension 2 Code");
            DimSetIDArr[3] := GetLedgEntryDimSetID(ContratoPlanningLine);
            DimSetIDArr[4] := GetContratoLedgEntryDimSetID(ContratoPlanningLine);
            DimMgt.CreateDimForSalesLineWithHigherPriorities(
                SalesLine, 0, DimSetIDArr[5],
                SalesLine."Shortcut Dimension 1 Code", SalesLine."Shortcut Dimension 2 Code",
                SourceCodeSetup.Sales, DATABASE::Contrato);
            SalesLine."Dimension Set ID" :=
                DimMgt.GetCombinedDimensionSetID(
                DimSetIDArr, SalesLine."Shortcut Dimension 1 Code", SalesLine."Shortcut Dimension 2 Code");
            Salesline.Modify();
        end;
    end;

    local procedure IsContratoInvCurrencyDependingOnBillingMethod(Contrato: Record Contrato; var ContratoPlanningLineSource: Record "Contrato Planning Line"): Boolean
    var
        ContratoTask: Record "Contrato Task";
    begin
        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
            exit(Contrato."Invoice Currency Code" <> '')
        else begin
            ContratoTask.Get(ContratoPlanningLineSource."Contrato No.", ContratoPlanningLineSource."Contrato Task No.");
            exit(ContratoTask."Invoice Currency Code" <> '');
        end;
    end;

    local procedure IsContratoInvCurrencyDependingOnBillingMethod(Contrato: Record Contrato; ContratoTask: Record "Contrato Task"): Boolean
    begin
        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
            exit(Contrato."Invoice Currency Code" <> '')
        else
            exit(ContratoTask."Invoice Currency Code" <> '');
    end;

    local procedure TestIfBillToCustomerExistOnContratoOrContratoTask(Contrato: Record Contrato; ContratoTask: Record "Contrato Task")
    begin
        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
            Contrato.TestField("Bill-to Customer No.")
        else
            ContratoTask.TestField("Bill-to Customer No.");
    end;

    local procedure ReturnBillToCustomerNoDependingOnTaskBillingMethod(Contrato: Record Contrato; ContratoTask2: Record "Contrato Task"): Code[20]
    var
        ContratoTask: Record "Contrato Task";
    begin
        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
            exit(Contrato."Bill-to Customer No.")
        else
            if ContratoTask.Get(TempContratoPlanningLine."Contrato No.", TempContratoPlanningLine."Contrato Task No.") then
                exit(ContratoTask."Bill-to Customer No.")
            else
                exit(ContratoTask2."Bill-to Customer No.");
    end;

    local procedure ReturnContratoDataDependingOnTaskBillingMethod(Contrato: Record Contrato; ContratoPlanningLine: Record "Contrato Planning Line"; FieldName: Text): Text[35]
    var
        ContratoTask: Record "Contrato Task";
        DataTypeMgt: Codeunit "Data Type Management";
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then begin
            RecRef.GetTable(Contrato);
            if DataTypeMgt.FindFieldByName(RecRef, FldRef, FieldName) then
                exit(FldRef.Value());
        end else begin
            ContratoTask.Get(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.");
            RecRef.GetTable(ContratoTask);
            if DataTypeMgt.FindFieldByName(RecRef, FldRef, FieldName) then
                exit(FldRef.Value());
        end;
    end;

#if not CLEAN24
    local procedure CheckContratoPlanningLineIsNegative(ContratoPlanningLine: Record "Contrato Planning Line")
    var
        IsHandled: Boolean;
    begin
        OnBeforeCheckContratoPlanningLineIsNegative(ContratoPlanningLine, IsHandled);
        if IsHandled then
            exit;
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateSalesInvoiceLines(SalesHeader: Record "Sales Header"; NewInvoice: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateSalesHeader(Contrato: Record Contrato; PostingDate: Date; var SalesHeader2: Record "Sales Header"; var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateSalesLine(var ContratoPlanningLine: Record "Contrato Planning Line"; var SalesHeader: Record "Sales Header"; var SalesHeader2: Record "Sales Header"; var ContratoInvCurrency: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateSalesLine(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; Contrato: Record Contrato; var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateSalesHeader(var SalesHeader: Record "Sales Header"; Contrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateNewInvoice(var ContratoTask: Record "Contrato Task"; InvoicePerTask: Boolean; var OldContratoNo: Code[20]; var OldContratoTaskNo: Code[20]; LastContratoTask: Boolean; var NewInvoice: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateSalesInvoiceLines(var ContratoPlanningLine: Record "Contrato Planning Line"; InvoiceNo: Code[20]; NewInvoice: Boolean; PostingDate: Date; CreditMemo: Boolean; var NoOfSalesLinesCreated: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateSalesInvoiceContratoTask(var ContratoTask2: Record "Contrato Task"; PostingDate: Date; InvoicePerTask: Boolean; var NoOfInvoices: Integer; var OldContratoNo: Code[20]; var OldContratoTaskNo: Code[20]; LastContratoTask: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteSalesLine(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetInvoiceNo(var ContratoPlanningLine: Record "Contrato Planning Line"; Done: Boolean; NewInvoice: Boolean; PostingDate: Date; var InvoiceNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetCrMemoNo(var ContratoPlanningLine: Record "Contrato Planning Line"; Done: Boolean; NewInvoice: Boolean; PostingDate: Date; var InvoiceNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertSalesHeader(var SalesHeader: Record "Sales Header"; Contrato: Record Contrato; ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifySalesHeader(var SalesHeader: Record "Sales Header"; Contrato: Record Contrato; ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertSalesLine(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; Contrato: Record Contrato; ContratoPlanningLine: Record "Contrato Planning Line"; ContratoInvCurrency: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifySalesLine(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; Contrato: Record Contrato; ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenSalesInvoice(var ContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestSalesHeader(var SalesHeader: Record "Sales Header"; Contrato: Record Contrato; var IsHandled: Boolean; var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTransferLine(var ContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateSalesHeader(var SalesHeader: Record "Sales Header"; Contrato: Record Contrato; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOpenSalesInvoice(var ContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestSalesHeader(var SalesHeader: Record "Sales Header"; Contrato: Record Contrato; ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckContratoBillToCustomer(ContratoPlanningLineSource: Record "Contrato Planning Line"; Contrato: Record Contrato; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindInvoices(var TempContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice" temporary; ContratoNo: Code[20]; ContratoTaskNo: Code[20]; ContratoPlanningLineNo: Integer; DetailLevel: Option; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowMessageLinesTransferred(var ContratoPlanningLine: Record "Contrato Planning Line"; CrMemo: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestExchangeRate(var ContratoPlanningLine: Record "Contrato Planning Line"; PostingDate: Date; var UpdateExchangeRates: Boolean; var CurrencyExchangeRate: Record "Currency Exchange Rate")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestTransferred(var ContratoPlanningLine: Record "Contrato Planning Line"; SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesLineOnAfterCalcShouldUpdateCurrencyFactor(var ContratoPlanningLine: Record "Contrato Planning Line"; var Contrato: Record Contrato; var SalesHeader: Record "Sales Header"; var SalesHeader2: Record "Sales Header"; var ContratoInvCurrency: Boolean; var ShouldUpdateCurrencyFactor: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesHeaderOnBeforeUpdateSalesHeader(var SalesHeader: Record "Sales Header"; var Contrato: Record Contrato; var IsHandled: Boolean; ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesLineOnBeforeSalesCheckIfAnyExtText(var ContratoPlanningLine: Record "Contrato Planning Line"; var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesLineOnBeforeValidateSalesLineNo(var ContratoPlanningLine: Record "Contrato Planning Line"; var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesLineOnAfterSalesLineModify(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; Contrato: Record Contrato; ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceLinesOnAfterValidateContratoPlanningLine(var ContratoPlanningLine: Record "Contrato Planning Line"; var LastError: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceLinesOnBeforeContratoPlanningLineFindSet(var ContratoPlanningLine: Record "Contrato Planning Line"; InvoiceNo: Code[20]; NewInvoice: Boolean; PostingDate: Date; CreditMemo: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceLinesOnBeforeContratoPlanningLineModify(var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceLinesOnBeforeCreateSalesLine(var ContratoPlanningLine: Record "Contrato Planning Line"; SalesHeader: Record "Sales Header"; SalesHeader2: Record "Sales Header"; NewInvoice: Boolean; var NoOfSalesLinesCreated: Integer)
    begin
    end;
#if not CLEAN23
    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceLinesOnBeforeGetCustomer(ContratoPlanningLine: Record "Contrato Planning Line"; var Customer: Record Customer; var IsHandled: Boolean)
    begin
    end;
#endif
    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceLinesOnBeforeTestContrato(var Contrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceContratoTaskOnAfterLinesCreated(var SalesHeader: Record "Sales Header"; var Contrato: Record Contrato; InvoicePerTask: Boolean; LastContratoTask: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceContratoTaskOnBeforeTempContratoPlanningLineFind(var ContratoTask: Record "Contrato Task"; var SalesHeader: Record "Sales Header"; InvoicePerTask: Boolean; var TempContratoPlanningLine: Record "Contrato Planning Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceContratoTaskOnBeforeCreateSalesLine(var ContratoPlanningLine: Record "Contrato Planning Line"; SalesHeader: Record "Sales Header"; SalesHeader2: Record "Sales Header"; var NoOfSalesLinesCreated: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceContratoTaskTestContrato(var Contrato: Record Contrato; var ContratoPlanningLine: Record "Contrato Planning Line"; PostingDate: Date)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteSalesLineOnBeforeContratoPlanningLineModify(var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceContratoTaskOnBeforeContratoPlanningLineInvoiceInsert(var ContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceOnBeforeRunReport(var ContratoPlanningLine: Record "Contrato Planning Line"; var Done: Boolean; var NewInvoice: Boolean; var PostingDate: Date; var InvoiceNo: Code[20]; var IsHandled: Boolean; CrMemo: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindInvoicesOnBeforeTempContratoPlanningLineInvoiceInsert(var TempContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice"; ContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindInvoicesOnBeforeTempContratoPlanningLineInvoiceModify(var TempContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice"; ContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesHeaderOnBeforeCheckBillToCustomerNo(var SalesHeader: Record "Sales Header"; Contrato: Record Contrato; ContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceLinesOnBeforeContratoPlanningLineCopy(Contrato: Record Contrato; var ContratoPlanningLineSource: Record "Contrato Planning Line"; PostingDate: Date)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateSalesLineDimension(var SalesLine: Record "Sales Line"; ContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

#if not CLEAN24
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckContratoPlanningLineIsNegative(ContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceLinesOnAfterSetContratoInvCurrency(Contrato: Record Contrato; var ContratoInvCurrency: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesLineOnBeforeValidateCurrencyCode(var IsHandled: Boolean; SalesLine: Record "Sales Line"; ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceLinesOnAfterSetSalesDocumentType(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeGetContratoPlanningLineInvoices(ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceContratoTaskOnAfterContratoPlanningLineSetFilters(var ContratoPlanningLine: Record "Contrato Planning Line"; var ContratoTask2: Record "Contrato Task")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesLineOnBeforeCheckPricesIncludingVATAndSetContratoInformation(var SalesLine: Record "Sales Line"; ContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteSalesLineOnBeforeGetContratoPlanningLine(ContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetCustomerNo(var Contrato: Record Contrato; var ContratoPlanningLine: Record "Contrato Planning Line"; SellToCustomerNo: Boolean; var CustomerNo: Code[20])
    begin
    end;
}

