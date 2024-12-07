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
        TempJobPlanningLine: Record "Contrato Planning Line" temporary;
        TempJobPlanningLine2: Record "Contrato Planning Line" temporary;
        TransferExtendedText: Codeunit "Transfer Extended Text";
        JobInvCurrency: Boolean;
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

    procedure CreateSalesInvoice(var JobPlanningLine: Record "Contrato Planning Line"; CrMemo: Boolean)
    var
        SalesHeader: Record "Sales Header";
        Contrato: Record Contrato;
        JobPlanningLine2: Record "Contrato Planning Line";
        GetSalesInvoiceNo: Report "Job Transfer to Sales Invoice";
        GetSalesCrMemoNo: Report "Job Transfer to Credit Memo";
        Done: Boolean;
        NewInvoice: Boolean;
        PostingDate: Date;
        DocumentDate: Date;
        InvoiceNo: Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnCreateSalesInvoiceOnBeforeRunReport(JobPlanningLine, Done, NewInvoice, PostingDate, InvoiceNo, IsHandled, CrMemo);
        if not IsHandled then
            if not CrMemo then begin
                //GetSalesInvoiceNo.SetCustomer(JobPlanningLine);
                GetSalesInvoiceNo.RunModal();
                IsHandled := false;
                OnBeforeGetInvoiceNo(JobPlanningLine, Done, NewInvoice, PostingDate, InvoiceNo, IsHandled);
                if not IsHandled then
                    GetSalesInvoiceNo.GetInvoiceNo(Done, NewInvoice, PostingDate, DocumentDate, InvoiceNo);
            end else begin
                //GetSalesCrMemoNo.SetCustomer(JobPlanningLine);
                GetSalesCrMemoNo.RunModal();
                IsHandled := false;
                OnBeforeGetCrMemoNo(JobPlanningLine, Done, NewInvoice, PostingDate, InvoiceNo, IsHandled);
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

            Contrato.Get(JobPlanningLine."Contrato No.");
            if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
                CreateSalesInvoiceLines(
                    JobPlanningLine."Contrato No.", JobPlanningLine, InvoiceNo, NewInvoice, PostingDate, DocumentDate, CrMemo)
            else begin
                JobPlanningLine2.Copy(JobPlanningLine);
                JobPlanningLine2.SetCurrentKey("Contrato No.", "Contrato Task No.", "Line No.");
                JobPlanningLine2.FindSet();
                JobPlanningLine.Reset();
                repeat
                    JobPlanningLine.SetFilter("Contrato No.", JobPlanningLine2."Contrato No.");
                    JobPlanningLine.SetFilter("Contrato Task No.", JobPlanningLine2."Contrato Task No.");
                    JobPlanningLine.SetFilter("Line No.", '%1', JobPlanningLine2."Line No.");
                    JobPlanningLine.FindFirst();
                    CreateSalesInvoiceLines(JobPlanningLine."Contrato No.", JobPlanningLine, InvoiceNo, NewInvoice, PostingDate, DocumentDate, CrMemo);
                until JobPlanningLine2.Next() = 0;
            end;

            Commit();

            ShowMessageLinesTransferred(JobPlanningLine, CrMemo);
        end;
    end;

    local procedure ShowMessageLinesTransferred(JobPlanningLine: Record "Contrato Planning Line"; CrMemo: Boolean)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeShowMessageLinesTransferred(JobPlanningLine, CrMemo, IsHandled);
        if IsHandled then
            exit;

        if CrMemo then
            Message(Text008)
        else
            Message(Text000);
    end;
#if not CLEAN23

    procedure CreateSalesInvoiceLines(JobNo: Code[20]; var JobPlanningLineSource: Record "Contrato Planning Line"; InvoiceNo: Code[20]; NewInvoice: Boolean; PostingDate: Date; CreditMemo: Boolean)
    begin
        CreateSalesInvoiceLines(JobNo, JobPlanningLineSource, InvoiceNo, NewInvoice, PostingDate, 0D, CreditMemo);
    end;
#endif
    procedure CreateSalesInvoiceLines(JobNo: Code[20]; var JobPlanningLineSource: Record "Contrato Planning Line"; InvoiceNo: Code[20]; NewInvoice: Boolean; PostingDate: Date; DocumentDate: Date; CreditMemo: Boolean)
    var
        Contrato: Record Contrato;
        JobPlanningLine: Record "Contrato Planning Line";
        JobPlanningLineInvoice: Record "Contrato Planning Line Invoice";
        LineCounter: Integer;
        LastError: Text;
    begin
        OnBeforeCreateSalesInvoiceLines(JobPlanningLineSource, InvoiceNo, NewInvoice, PostingDate, CreditMemo, NoOfSalesLinesCreated);

        ClearAll();
        Contrato.Get(JobNo);
        OnCreateSalesInvoiceLinesOnBeforeTestJob(Contrato);
        // if Contrato.Blocked = Contrato.Blocked::All then
        //     Contrato.TestBlocked();
        if Contrato."Currency Code" = '' then
            JobInvCurrency := IsJobInvCurrencyDependingOnBillingMethod(Contrato, JobPlanningLineSource);

        OnCreateSalesInvoiceLinesOnAfterSetJobInvCurrency(Contrato, JobInvCurrency);
        CheckJobBillToCustomer(JobPlanningLineSource, Contrato);

        if CreditMemo then
            SalesHeader2."Document Type" := SalesHeader2."Document Type"::"Credit Memo"
        else
            SalesHeader2."Document Type" := SalesHeader2."Document Type"::Invoice;

        OnCreateSalesInvoiceLinesOnAfterSetSalesDocumentType(SalesHeader2);

        if not NewInvoice then
            SalesHeader.Get(SalesHeader2."Document Type", InvoiceNo);

        OnCreateSalesInvoiceLinesOnBeforeJobPlanningLineCopy(Contrato, JobPlanningLineSource, PostingDate);
        JobPlanningLine.Copy(JobPlanningLineSource);
        JobPlanningLine.SetCurrentKey("Contrato No.", "Contrato Task No.", "Line No.");

        OnCreateSalesInvoiceLinesOnBeforeJobPlanningLineFindSet(JobPlanningLine, InvoiceNo, NewInvoice, PostingDate, CreditMemo);
        if JobPlanningLine.FindSet() then
            repeat
                if TransferLine(JobPlanningLine) then begin
                    LineCounter := LineCounter + 1;
                    if (JobPlanningLine."Contrato No." <> JobNo) and (not JobPlanningLineSource.GetSkipCheckForMultipleJobsOnSalesLine()) then
                        LastError := StrSubstNo(Text009, JobPlanningLine.FieldCaption("Contrato No."));
                    OnCreateSalesInvoiceLinesOnAfterValidateJobPlanningLine(JobPlanningLine, LastError);
                    if LastError <> '' then
                        Error(LastError);
                    if NewInvoice then
                        TestExchangeRate(JobPlanningLine, PostingDate)
                    else
                        TestExchangeRate(JobPlanningLine, SalesHeader."Posting Date");
                end;
            until JobPlanningLine.Next() = 0;

        if LineCounter = 0 then
            Error(Text002,
              JobPlanningLine.TableCaption(),
              JobPlanningLine.FieldCaption("Qty. to Transfer to Invoice"));

        if NewInvoice then
            CreateSalesHeader(Contrato, PostingDate, DocumentDate, JobPlanningLine)
        else
            TestSalesHeader(SalesHeader, Contrato, JobPlanningLine);
        if JobPlanningLine.Find('-') then
            repeat
                if TransferLine(JobPlanningLine) then begin
                    if JobPlanningLine.Type in [JobPlanningLine.Type::Resource,
                                                JobPlanningLine.Type::Item,
                                                JobPlanningLine.Type::"G/L Account"]
                    then
                        JobPlanningLine.TestField("No.");

                    OnCreateSalesInvoiceLinesOnBeforeCreateSalesLine(
                      JobPlanningLine, SalesHeader, SalesHeader2, NewInvoice, NoOfSalesLinesCreated);
#if not CLEAN24
                    if not CreditMemo then
                        CheckJobPlanningLineIsNegative(JobPlanningLine);
#endif

                    CreateSalesLine(JobPlanningLine);

                    JobPlanningLineInvoice.InitFromJobPlanningLine(JobPlanningLine);
                    if NewInvoice then
                        JobPlanningLineInvoice.InitFromSales(SalesHeader, PostingDate, SalesLine."Line No.")
                    else
                        JobPlanningLineInvoice.InitFromSales(SalesHeader, SalesHeader."Posting Date", SalesLine."Line No.");
                    JobPlanningLineInvoice.Insert();

                    JobPlanningLine.UpdateQtyToTransfer();
                    OnCreateSalesInvoiceLinesOnBeforeJobPlanningLineModify(JobPlanningLine);
                    JobPlanningLine.Modify();
                end;
            until JobPlanningLine.Next() = 0;

        JobPlanningLineSource.Get(
          JobPlanningLineSource."Contrato No.", JobPlanningLineSource."Contrato Task No.", JobPlanningLineSource."Line No.");
        JobPlanningLineSource.CalcFields("Qty. Transferred to Invoice");

        if NoOfSalesLinesCreated = 0 then
            Error(Text002, JobPlanningLine.TableCaption(), JobPlanningLine.FieldCaption("Qty. to Transfer to Invoice"));

        OnAfterCreateSalesInvoiceLines(SalesHeader, NewInvoice);
    end;

    local procedure CheckJobBillToCustomer(var JobPlanningLineSource: Record "Contrato Planning Line"; Contrato: Record Contrato)
    var
        JobTask: Record "Contrato Task";
        Cust: Record Customer;
        BillToCustomerNo: Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckJobBillToCustomer(JobPlanningLineSource, Contrato, IsHandled);
        if IsHandled then
            exit;
        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then begin
            Contrato.TestField("Bill-to Customer No.");
            BillToCustomerNo := Contrato."Bill-to Customer No.";
        end else begin
            JobTask.Get(JobPlanningLineSource."Contrato No.", JobPlanningLineSource."Contrato Task No.");
            JobTask.TestField("Bill-to Customer No.");
            BillToCustomerNo := JobTask."Bill-to Customer No.";
        end;
#if not CLEAN23
        IsHandled := false;
        OnCreateSalesInvoiceLinesOnBeforeGetCustomer(JobPlanningLineSource, Cust, IsHandled);
        if not IsHandled then
#endif
            Cust.Get(BillToCustomerNo);
    end;

    procedure DeleteSalesInvoiceBuffer()
    begin
        ClearAll();
        TempJobPlanningLine.DeleteAll();
    end;
#if not CLEAN23

    procedure CreateSalesInvoiceJobTask(var JobTask2: Record "Contrato Task"; PostingDate: Date; InvoicePerTask: Boolean; var NoOfInvoices: Integer; var OldJobNo: Code[20]; var OldJobTaskNo: Code[20]; LastJobTask: Boolean)
    begin
        CreateSalesInvoiceJobTask(JobTask2, PostingDate, 0D, InvoicePerTask, NoOfInvoices, OldJobNo, OldJobTaskNo, LastJobTask);
    end;
#endif
    procedure CreateSalesInvoiceJobTask(var JobTask2: Record "Contrato Task"; PostingDate: Date; DocumentDate: Date; InvoicePerTask: Boolean; var NoOfInvoices: Integer; var OldJobNo: Code[20]; var OldJobTaskNo: Code[20]; LastJobTask: Boolean)
    var
        Cust: Record Customer;
        Contrato: Record Contrato;
        JobTask: Record "Contrato Task";
        JobPlanningLine: Record "Contrato Planning Line";
        JobPlanningLineInvoice: Record "Contrato Planning Line Invoice";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateSalesInvoiceJobTask(
          JobTask2, PostingDate, InvoicePerTask, NoOfInvoices, OldJobNo, OldJobTaskNo, LastJobTask, IsHandled);
        if IsHandled then
            exit;

        ClearAll();
        if not LastJobTask then begin
            JobTask := JobTask2;
            if JobTask."Contrato No." = '' then
                exit;
            if JobTask."Contrato Task No." = '' then
                exit;
            JobTask.Find();
            if JobTask."Contrato Task Type" <> JobTask."Contrato Task Type"::Posting then
                exit;
            Contrato.Get(JobTask."Contrato No.");
        end;
        if LastJobTask then begin
            if not TempJobPlanningLine.Find('-') then
                exit;
            Contrato.Get(TempJobPlanningLine."Contrato No.");
            JobTask.Get(TempJobPlanningLine."Contrato No.", TempJobPlanningLine."Contrato Task No.");
        end;

        OnCreateSalesInvoiceJobTaskTestJob(Contrato, JobPlanningLine, PostingDate);
        TestIfBillToCustomerExistOnJobOrJobTask(Contrato, JobTask2);
        // if Contrato.Blocked = Contrato.Blocked::All then
        //     Contrato.TestBlocked();
        if Contrato."Currency Code" = '' then
            JobInvCurrency := IsJobInvCurrencyDependingOnBillingMethod(Contrato, JobTask2);
        Cust.Get(ReturnBillToCustomerNoDependingOnTaskBillingMethod(Contrato, JobTask2));

        if CreateNewInvoice(JobTask, InvoicePerTask, OldJobNo, OldJobTaskNo, LastJobTask) then begin
            Contrato.Get(TempJobPlanningLine."Contrato No.");
            Cust.Get(ReturnBillToCustomerNoDependingOnTaskBillingMethod(Contrato, JobTask2));
            SalesHeader2."Document Type" := SalesHeader2."Document Type"::Invoice;
            if not SalesInvoiceExistForMultipleCustomerBillingMethod(Contrato) then begin
                CreateSalesHeader(Contrato, PostingDate, DocumentDate, TempJobPlanningLine);
                NoOfInvoices := NoOfInvoices + 1;
            end;
            OnCreateSalesInvoiceJobTaskOnBeforeTempJobPlanningLineFind(JobTask, SalesHeader, InvoicePerTask, TempJobPlanningLine);
            if TempJobPlanningLine.Find('-') then
                repeat
                    Contrato.Get(TempJobPlanningLine."Contrato No.");
                    JobInvCurrency := (Contrato."Currency Code" = '') and IsJobInvCurrencyDependingOnBillingMethod(Contrato, TempJobPlanningLine);
                    JobPlanningLine := TempJobPlanningLine;
                    JobPlanningLine.Find();
                    if JobPlanningLine.Type in [JobPlanningLine.Type::Resource,
                                                JobPlanningLine.Type::Item,
                                                JobPlanningLine.Type::"G/L Account"]
                    then
                        JobPlanningLine.TestField("No.");
                    TestExchangeRate(JobPlanningLine, PostingDate);

                    OnCreateSalesInvoiceJobTaskOnBeforeCreateSalesLine(JobPlanningLine, SalesHeader, SalesHeader2, NoOfSalesLinesCreated);
                    CreateSalesLine(JobPlanningLine);

                    JobPlanningLineInvoice."Contrato No." := JobPlanningLine."Contrato No.";
                    JobPlanningLineInvoice."Contrato Task No." := JobPlanningLine."Contrato Task No.";
                    JobPlanningLineInvoice."Contrato Planning Line No." := JobPlanningLine."Line No.";
                    if SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice then
                        JobPlanningLineInvoice."Document Type" := JobPlanningLineInvoice."Document Type"::Invoice;
                    if SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo" then
                        JobPlanningLineInvoice."Document Type" := JobPlanningLineInvoice."Document Type"::"Credit Memo";
                    JobPlanningLineInvoice."Document No." := SalesHeader."No.";
                    JobPlanningLineInvoice."Line No." := SalesLine."Line No.";
                    JobPlanningLineInvoice."Quantity Transferred" := JobPlanningLine."Qty. to Transfer to Invoice";
                    JobPlanningLineInvoice."Transferred Date" := PostingDate;
                    OnCreateSalesInvoiceJobTaskOnBeforeJobPlanningLineInvoiceInsert(JobPlanningLineInvoice);
                    JobPlanningLineInvoice.Insert();

                    JobPlanningLine.UpdateQtyToTransfer();
                    JobPlanningLine.Modify();
                until TempJobPlanningLine.Next() = 0;
            TempJobPlanningLine.DeleteAll();
        end;

        OnCreateSalesInvoiceJobTaskOnAfterLinesCreated(SalesHeader, Contrato, InvoicePerTask, LastJobTask);

        if LastJobTask then begin
            if NoOfSalesLinesCreated = 0 then
                Error(Text002, JobPlanningLine.TableCaption(), JobPlanningLine.FieldCaption("Qty. to Transfer to Invoice"));
            exit;
        end;

        JobPlanningLine.Reset();
        JobPlanningLine.SetCurrentKey("Contrato No.", "Contrato Task No.");
        JobPlanningLine.SetRange("Contrato No.", JobTask2."Contrato No.");
        JobPlanningLine.SetRange("Contrato Task No.", JobTask2."Contrato Task No.");
        JobPlanningLine.SetFilter("Planning Date", JobTask2.GetFilter("Planning Date Filter"));
        OnCreateSalesInvoiceJobTaskOnAfterJobPlanningLineSetFilters(JobPlanningLine, JobTask2);
        if JobPlanningLine.Find('-') then
            repeat
                if TransferLine(JobPlanningLine) then begin
                    TempJobPlanningLine := JobPlanningLine;
                    TempJobPlanningLine.Insert();

                    if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"Multiple customers" then begin
                        TempJobPlanningLine2 := JobPlanningLine;
                        TempJobPlanningLine2.Insert();
                    end;
                end;
            until JobPlanningLine.Next() = 0;
    end;

    local procedure CreateNewInvoice(var JobTask: Record "Contrato Task"; InvoicePerTask: Boolean; var OldJobNo: Code[20]; var OldJobTaskNo: Code[20]; LastJobTask: Boolean): Boolean
    var
        NewInvoice: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateNewInvoice(JobTask, InvoicePerTask, OldJobNo, OldJobTaskNo, LastJobTask, NewInvoice, IsHandled);
        if IsHandled then
            exit(NewInvoice);

        if LastJobTask then
            NewInvoice := true
        else begin
            if OldJobNo <> '' then begin
                if InvoicePerTask then
                    if (OldJobNo <> JobTask."Contrato No.") or (OldJobTaskNo <> JobTask."Contrato Task No.") then
                        NewInvoice := true;
                if not InvoicePerTask then
                    if OldJobNo <> JobTask."Contrato No." then
                        NewInvoice := true;
            end;
            OldJobNo := JobTask."Contrato No.";
            OldJobTaskNo := JobTask."Contrato Task No.";
        end;
        if not TempJobPlanningLine.Find('-') then
            NewInvoice := false;
        exit(NewInvoice);
    end;

    local procedure CreateSalesHeader(Contrato: Record Contrato; PostingDate: Date; DocumentDate: Date; JobPlanningLine: Record "Contrato Planning Line")
    var
        JobTask: Record "Contrato Task";
        SalesSetup: Record "Sales & Receivables Setup";
        IsHandled: Boolean;
    begin
        OnBeforeCreateSalesHeader(Contrato, PostingDate, SalesHeader2, JobPlanningLine);

        SalesSetup.Get();
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader2."Document Type";
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice then
            SalesSetup.TestField("Invoice Nos.");
        if SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo" then
            SalesSetup.TestField("Credit Memo Nos.");
        SalesHeader."Posting Date" := PostingDate;
        SalesHeader."Document Date" := DocumentDate;
        OnBeforeInsertSalesHeader(SalesHeader, Contrato, JobPlanningLine);
        SalesHeader.Insert(true);

        IsHandled := false;
        OnCreateSalesHeaderOnBeforeCheckBillToCustomerNo(SalesHeader, Contrato, JobPlanningLine, IsHandled);

        if not IsHandled then begin
            SalesHeader.SetHideValidationDialog(true);
            SalesHeader.Validate("Sell-to Customer No.", GetCustomerNo(Contrato, JobPlanningLine, true));
            SalesHeader.Validate("Bill-to Customer No.", GetCustomerNo(Contrato, JobPlanningLine, false));
        end;

        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then begin
            if Contrato."Payment Method Code" <> '' then
                SalesHeader.Validate("Payment Method Code", Contrato."Payment Method Code");
            if Contrato."Payment Terms Code" <> '' then
                SalesHeader.Validate("Payment Terms Code", Contrato."Payment Terms Code");
            if Contrato."External Document No." <> '' then
                SalesHeader.Validate("External Document No.", Contrato."External Document No.");
        end else begin
            JobTask.Get(JobPlanningLine."Contrato No.", JobPlanningLine."Contrato Task No.");
            if JobTask."Payment Method Code" <> '' then
                SalesHeader.Validate("Payment Method Code", JobTask."Payment Method Code");
            if JobTask."Payment Terms Code" <> '' then
                SalesHeader.Validate("Payment Terms Code", JobTask."Payment Terms Code");
            if JobTask."External Document No." <> '' then
                SalesHeader.Validate("External Document No.", JobTask."External Document No.");
        end;

        if Contrato."Currency Code" <> '' then
            SalesHeader.Validate("Currency Code", Contrato."Currency Code")
        else
            SalesHeader.Validate("Currency Code", ReturnJobDataDependingOnTaskBillingMethod(Contrato, JobPlanningLine, 'Invoice Currency Code'));

        if PostingDate <> 0D then
            SalesHeader.Validate("Posting Date", PostingDate);
        if DocumentDate <> 0D then
            SalesHeader.Validate("Document Date", DocumentDate);

        SalesHeader."Your Reference" := ReturnJobDataDependingOnTaskBillingMethod(Contrato, JobPlanningLine, 'Your Reference');

        if SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice then
            SalesHeader.SetDefaultPaymentServices();

        IsHandled := false;
        OnCreateSalesHeaderOnBeforeUpdateSalesHeader(SalesHeader, Contrato, IsHandled, JobPlanningLine);
        if not IsHandled then
            if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
                UpdateSalesHeader(SalesHeader, Contrato)
            else
                UpdateSalesHeader(SalesHeader, JobPlanningLine);
        OnBeforeModifySalesHeader(SalesHeader, Contrato, JobPlanningLine);
        SalesHeader.Modify(true);
    end;

    local procedure SalesInvoiceExistForMultipleCustomerBillingMethod(Contrato: Record Contrato): Boolean
    var
        JobTask: Record "Contrato Task";
        JobTask2: Record "Contrato Task";
        JobPlanningLineInvoice: Record "Contrato Planning Line Invoice";
        TempJobPlanningLine3: Record "Contrato Planning Line" temporary;
        SelectionFilterMgt: Codeunit SelectionFilterManagement;
        RecRef: RecordRef;
        JobTaskFilter: Text;
    begin
        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
            exit;

        TempJobPlanningLine3.Copy(TempJobPlanningLine2, true);
        TempJobPlanningLine3.Reset();
        TempJobPlanningLine3.SetFilter("Contrato Contract Entry No.", '<>%1', TempJobPlanningLine."Contrato Contract Entry No.");
        RecRef.GetTable(TempJobPlanningLine3);
        JobTaskFilter := SelectionFilterMgt.GetSelectionFilter(RecRef, TempJobPlanningLine3.FieldNo("Contrato Task No."));
        if JobTaskFilter = '' then
            exit;

        if JobTask.Get(TempJobPlanningLine."Contrato No.", TempJobPlanningLine."Contrato Task No.") then begin
            JobTask2.SetRange("Contrato No.", Contrato."No.");
            JobTask2.SetFilter("Contrato Task No.", JobTaskFilter);
            JobTask2.SetRange("Sell-to Customer No.", JobTask."Sell-to Customer No.");
            JobTask2.SetRange("Bill-to Customer No.", JobTask."Bill-to Customer No.");
            JobTask2.SetRange("Invoice Currency Code", JobTask."Invoice Currency Code");
            if JobTask2.FindFirst() then begin
                JobPlanningLineInvoice.SetRange("Contrato No.", Contrato."No.");
                JobPlanningLineInvoice.SetRange("Contrato Task No.", JobTask2."Contrato Task No.");
                JobPlanningLineInvoice.SetRange("Document Type", JobPlanningLineInvoice."Document Type"::Invoice);
                if JobPlanningLineInvoice.FindFirst() then begin
                    SalesHeader.Get(SalesHeader."Document Type"::Invoice, JobPlanningLineInvoice."Document No.");
                    exit(true);
                end;
            end;
        end;
    end;

    local procedure GetCustomerNo(Contrato: Record Contrato; JobPlanningLine: Record "Contrato Planning Line"; SellToCustomerNo: Boolean) CustomerNo: Code[20]
    var
        JobTask: Record "Contrato Task";
    begin
        OnBeforeGetCustomerNo(Contrato, JobPlanningLine, SellToCustomerNo, CustomerNo);
        if CustomerNo <> '' then
            exit(CustomerNo);

        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
            if SellToCustomerNo then
                exit(Contrato."Sell-to Customer No.")
            else
                exit(Contrato."Bill-to Customer No.");

        JobTask.Get(JobPlanningLine."Contrato No.", JobPlanningLine."Contrato Task No.");
        if SellToCustomerNo then
            exit(JobTask."Sell-to Customer No.")
        else
            exit(JobTask."Bill-to Customer No.");
    end;

    local procedure CreateSalesLine(var JobPlanningLine: Record "Contrato Planning Line")
    var
        Contrato: Record Contrato;
        Factor: Integer;
        IsHandled: Boolean;
        ShouldUpdateCurrencyFactor: Boolean;
    begin
        OnBeforeCreateSalesLine(JobPlanningLine, SalesHeader, SalesHeader2, JobInvCurrency);

        Factor := 1;
        if SalesHeader2."Document Type" = SalesHeader2."Document Type"::"Credit Memo" then
            Factor := -1;
        TestTransferred(JobPlanningLine);
        JobPlanningLine.TestField("Planning Date");
        Contrato.Get(JobPlanningLine."Contrato No.");
        Clear(SalesLine);
        SalesLine."Document Type" := SalesHeader2."Document Type";
        SalesLine."Document No." := SalesHeader."No.";

        ShouldUpdateCurrencyFactor := (not JobInvCurrency) and (JobPlanningLine.Type <> JobPlanningLine.Type::Text);
        OnCreateSalesLineOnAfterCalcShouldUpdateCurrencyFactor(JobPlanningLine, Contrato, SalesHeader, SalesHeader2, JobInvCurrency, ShouldUpdateCurrencyFactor);
        if ShouldUpdateCurrencyFactor then begin
            SalesHeader.TestField("Currency Code", JobPlanningLine."Currency Code");
            if (Contrato."Currency Code" <> '') and (JobPlanningLine."Currency Factor" <> SalesHeader."Currency Factor") then
                if Confirm(Text011) then begin
                    JobPlanningLine.Validate("Currency Factor", SalesHeader."Currency Factor");
                    JobPlanningLine.Modify();
                end else
                    Error(Text001);
            SalesHeader.TestField("Currency Code", Contrato."Currency Code");
        end;
        if JobPlanningLine.Type = JobPlanningLine.Type::Text then
            SalesLine.Validate(Type, SalesLine.Type::" ");
        if JobPlanningLine.Type = JobPlanningLine.Type::"G/L Account" then
            SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        if JobPlanningLine.Type = JobPlanningLine.Type::Item then
            SalesLine.Validate(Type, SalesLine.Type::Item);
        if JobPlanningLine.Type = JobPlanningLine.Type::Resource then
            SalesLine.Validate(Type, SalesLine.Type::Resource);


        IsHandled := false;
        OnCreateSalesLineOnBeforeValidateSalesLineNo(JobPlanningLine, SalesLine, IsHandled);
        if not IsHandled then
            SalesLine.Validate("No.", JobPlanningLine."No.");
        SalesLine.Validate("Gen. Prod. Posting Group", JobPlanningLine."Gen. Prod. Posting Group");
        SalesLine.Validate("Location Code", JobPlanningLine."Location Code");
        SalesLine.Validate("Work Type Code", JobPlanningLine."Work Type Code");
        SalesLine.Validate("Variant Code", JobPlanningLine."Variant Code");

        if SalesLine.Type <> SalesLine.Type::" " then begin
            SalesLine.Validate("Unit of Measure Code", JobPlanningLine."Unit of Measure Code");
            SalesLine.Validate(Quantity, Factor * JobPlanningLine."Qty. to Transfer to Invoice");
            if JobPlanningLine."Bin Code" <> '' then
                SalesLine."Bin Code" := JobPlanningLine."Bin Code";
            if JobInvCurrency then begin
                OnCreateSalesLineOnBeforeValidateCurrencyCode(IsHandled, SalesLine, JobPlanningLine);
                if not IsHandled then begin
                    Currency.Get(SalesLine."Currency Code");
                    SalesLine.Validate("Unit Price",
                    Round(JobPlanningLine."Unit Price" * SalesHeader."Currency Factor",
                        Currency."Unit-Amount Rounding Precision"));
                end;
            end else
                SalesLine.Validate("Unit Price", JobPlanningLine."Unit Price");
            SalesLine.Validate("Unit Cost (LCY)", JobPlanningLine."Unit Cost (LCY)");
            SalesLine.Validate("Line Discount %", JobPlanningLine."Line Discount %");
            SalesLine."Inv. Discount Amount" := 0;
            SalesLine."Inv. Disc. Amount to Invoice" := 0;
            SalesLine.UpdateAmounts();
        end;

        IsHandled := false;
        OnCreateSalesLineOnBeforeCheckPricesIncludingVATAndSetJobInformation(SalesLine, JobPlanningLine, IsHandled);
        if not IsHandled then begin
            if not SalesHeader."Prices Including VAT" then
                SalesLine.Validate("Job Contract Entry No.", JobPlanningLine."Contrato Contract Entry No.");
            SalesLine."Job No." := JobPlanningLine."Contrato No.";
            SalesLine."Job Task No." := JobPlanningLine."Contrato Task No.";
        end;
        SalesLine.Description := JobPlanningLine.Description;
        SalesLine."Description 2" := JobPlanningLine."Description 2";
        SalesLine."Line No." := GetNextLineNo(SalesLine);
        OnBeforeInsertSalesLine(SalesLine, SalesHeader, Contrato, JobPlanningLine, JobInvCurrency);
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
            SalesLine.Validate("Job Contract Entry No.", JobPlanningLine."Contrato Contract Entry No.");
            OnBeforeModifySalesLine(SalesLine, SalesHeader, Contrato, JobPlanningLine);
            SalesLine.Modify();
            OnCreateSalesLineOnAfterSalesLineModify(SalesLine, SalesHeader, Contrato, JobPlanningLine);
            JobPlanningLine."VAT Unit Price" := SalesLine."Unit Price";
            JobPlanningLine."VAT Line Discount Amount" := SalesLine."Line Discount Amount";
            JobPlanningLine."VAT Line Amount" := SalesLine."Line Amount";
            JobPlanningLine."VAT %" := SalesLine."VAT %";
        end;
        if SalesLine."Job Task No." <> '' then
            UpdateSalesLineDimension(SalesLine, JobPlanningLine);

        IsHandled := false;
        OnCreateSalesLineOnBeforeSalesCheckIfAnyExtText(JobPlanningLine, SalesLine, IsHandled);
        if not IsHandled then
            if TransferExtendedText.SalesCheckIfAnyExtText(SalesLine, false) then
                TransferExtendedText.InsertSalesExtText(SalesLine);

        OnAfterCreateSalesLine(SalesLine, SalesHeader, Contrato, JobPlanningLine);
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

    local procedure TransferLine(var JobPlanningLine: Record "Contrato Planning Line"): Boolean
    var
        IsHandled, Result : Boolean;
    begin
        IsHandled := false;
        OnBeforeTransferLine(JobPlanningLine, IsHandled, Result);
        if IsHandled then
            exit(Result);

        if not JobPlanningLine."Contract Line" then
            exit(false);
        if JobPlanningLine.Type = JobPlanningLine.Type::Text then
            exit(true);
        exit(JobPlanningLine."Qty. to Transfer to Invoice" <> 0);
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

    local procedure TestTransferred(JobPlanningLine: Record "Contrato Planning Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestTransferred(JobPlanningLine, SalesHeader2, IsHandled);
        if IsHandled then
            exit;

        JobPlanningLine.CalcFields("Qty. Transferred to Invoice");
        if JobPlanningLine.Quantity > 0 then begin
            if (JobPlanningLine."Qty. to Transfer to Invoice" > 0) and (JobPlanningLine."Qty. to Transfer to Invoice" > (JobPlanningLine.Quantity - JobPlanningLine."Qty. Transferred to Invoice")) or
                (JobPlanningLine."Qty. to Transfer to Invoice" < 0)
            then
                Error(Text003, JobPlanningLine.FieldCaption("Qty. to Transfer to Invoice"), 0, JobPlanningLine.Quantity - JobPlanningLine."Qty. Transferred to Invoice");
        end else
            if (JobPlanningLine."Qty. to Transfer to Invoice" > 0) or
                (JobPlanningLine."Qty. to Transfer to Invoice" < 0) and (JobPlanningLine."Qty. to Transfer to Invoice" < (JobPlanningLine.Quantity - JobPlanningLine."Qty. Transferred to Invoice"))
            then
                Error(Text003, JobPlanningLine.FieldCaption("Qty. to Transfer to Invoice"), JobPlanningLine.Quantity - JobPlanningLine."Qty. Transferred to Invoice", 0);
    end;

    procedure DeleteSalesLine(SalesLine: Record "Sales Line")
    var
        JobPlanningLineInvoice: Record "Contrato Planning Line Invoice";
        JobPlanningLine: Record "Contrato Planning Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeDeleteSalesLine(SalesLine, IsHandled);
        if IsHandled then
            exit;

        case SalesLine."Document Type" of
            SalesLine."Document Type"::Invoice:
                JobPlanningLineInvoice.SetRange("Document Type", JobPlanningLineInvoice."Document Type"::Invoice);
            SalesLine."Document Type"::"Credit Memo":
                JobPlanningLineInvoice.SetRange("Document Type", JobPlanningLineInvoice."Document Type"::"Credit Memo");
        end;
        JobPlanningLineInvoice.SetRange("Document No.", SalesLine."Document No.");
        JobPlanningLineInvoice.SetRange("Line No.", SalesLine."Line No.");
        if JobPlanningLineInvoice.FindSet() then
            repeat
                OnDeleteSalesLineOnBeforeGetJobPlanningLine(JobPlanningLineInvoice);
                JobPlanningLine.Get(JobPlanningLineInvoice."Contrato No.", JobPlanningLineInvoice."Contrato Task No.", JobPlanningLineInvoice."Contrato Planning Line No.");
                JobPlanningLineInvoice.Delete();
                JobPlanningLine.UpdateQtyToTransfer();
                OnDeleteSalesLineOnBeforeJobPlanningLineModify(JobPlanningLine);
                JobPlanningLine.Modify();
            until JobPlanningLineInvoice.Next() = 0;
    end;

    procedure FindInvoices(var TempJobPlanningLineInvoice: Record "Contrato Planning Line Invoice" temporary; JobNo: Code[20]; JobTaskNo: Code[20]; JobPlanningLineNo: Integer; DetailLevel: Option All,"Per Contrato","Per Contrato Task","Per Contrato Planning Line")
    var
        JobPlanningLineInvoice: Record "Contrato Planning Line Invoice";
        RecordFound: Boolean;
        IsHandled: Boolean;
    begin
        OnBeforeFindInvoices(TempJobPlanningLineInvoice, JobNo, JobTaskNo, JobPlanningLineNo, DetailLevel, IsHandled);
        if IsHandled then
            exit;

        case DetailLevel of
            DetailLevel::All:
                begin
                    if JobPlanningLineInvoice.FindSet() then
                        TempJobPlanningLineInvoice := JobPlanningLineInvoice;
                    exit;
                end;
            DetailLevel::"Per Contrato":
                JobPlanningLineInvoice.SetRange("Contrato No.", JobNo);
            DetailLevel::"Per Contrato Task":
                begin
                    JobPlanningLineInvoice.SetRange("Contrato No.", JobNo);
                    JobPlanningLineInvoice.SetRange("Contrato Task No.", JobTaskNo);
                end;
            DetailLevel::"Per Contrato Planning Line":
                begin
                    JobPlanningLineInvoice.SetRange("Contrato No.", JobNo);
                    JobPlanningLineInvoice.SetRange("Contrato Task No.", JobTaskNo);
                    JobPlanningLineInvoice.SetRange("Contrato Planning Line No.", JobPlanningLineNo);
                end;
        end;

        TempJobPlanningLineInvoice.DeleteAll();
        if JobPlanningLineInvoice.FindSet() then
            repeat
                RecordFound := false;
                case DetailLevel of
                    DetailLevel::"Per Contrato":
                        if TempJobPlanningLineInvoice.Get(
                             JobNo, '', 0, JobPlanningLineInvoice."Document Type", JobPlanningLineInvoice."Document No.", 0)
                        then
                            RecordFound := true;
                    DetailLevel::"Per Contrato Task":
                        if TempJobPlanningLineInvoice.Get(
                             JobNo, JobTaskNo, 0, JobPlanningLineInvoice."Document Type", JobPlanningLineInvoice."Document No.", 0)
                        then
                            RecordFound := true;
                    DetailLevel::"Per Contrato Planning Line":
                        if TempJobPlanningLineInvoice.Get(
                             JobNo, JobTaskNo, JobPlanningLineNo, JobPlanningLineInvoice."Document Type", JobPlanningLineInvoice."Document No.", 0)
                        then
                            RecordFound := true;
                end;

                if RecordFound then begin
                    TempJobPlanningLineInvoice."Quantity Transferred" += JobPlanningLineInvoice."Quantity Transferred";
                    TempJobPlanningLineInvoice."Invoiced Amount (LCY)" += JobPlanningLineInvoice."Invoiced Amount (LCY)";
                    TempJobPlanningLineInvoice."Invoiced Cost Amount (LCY)" += JobPlanningLineInvoice."Invoiced Cost Amount (LCY)";
                    OnFindInvoicesOnBeforeTempJobPlanningLineInvoiceModify(TempJobPlanningLineInvoice, JobPlanningLineInvoice);
                    TempJobPlanningLineInvoice.Modify();
                end else begin
                    case DetailLevel of
                        DetailLevel::"Per Contrato":
                            TempJobPlanningLineInvoice."Contrato No." := JobNo;
                        DetailLevel::"Per Contrato Task":
                            begin
                                TempJobPlanningLineInvoice."Contrato No." := JobNo;
                                TempJobPlanningLineInvoice."Contrato Task No." := JobTaskNo;
                            end;
                        DetailLevel::"Per Contrato Planning Line":
                            begin
                                TempJobPlanningLineInvoice."Contrato No." := JobNo;
                                TempJobPlanningLineInvoice."Contrato Task No." := JobTaskNo;
                                TempJobPlanningLineInvoice."Contrato Planning Line No." := JobPlanningLineNo;
                            end;
                    end;
                    TempJobPlanningLineInvoice."Document Type" := JobPlanningLineInvoice."Document Type";
                    TempJobPlanningLineInvoice."Document No." := JobPlanningLineInvoice."Document No.";
                    TempJobPlanningLineInvoice."Quantity Transferred" := JobPlanningLineInvoice."Quantity Transferred";
                    TempJobPlanningLineInvoice."Invoiced Amount (LCY)" := JobPlanningLineInvoice."Invoiced Amount (LCY)";
                    TempJobPlanningLineInvoice."Invoiced Cost Amount (LCY)" := JobPlanningLineInvoice."Invoiced Cost Amount (LCY)";
                    TempJobPlanningLineInvoice."Invoiced Date" := JobPlanningLineInvoice."Invoiced Date";
                    TempJobPlanningLineInvoice."Transferred Date" := JobPlanningLineInvoice."Transferred Date";
                    OnFindInvoicesOnBeforeTempJobPlanningLineInvoiceInsert(TempJobPlanningLineInvoice, JobPlanningLineInvoice);
                    TempJobPlanningLineInvoice.Insert();
                end;
            until JobPlanningLineInvoice.Next() = 0;
    end;

    procedure GetJobPlanningLineInvoices(JobPlanningLine: Record "Contrato Planning Line")
    var
        JobPlanningLineInvoice: Record "Contrato Planning Line Invoice";
    begin
        OnBeforeGetJobPlanningLineInvoices(JobPlanningLine);

        ClearAll();
        if JobPlanningLine."Line No." = 0 then
            exit;

        JobPlanningLine.TestField("Contrato No.");
        JobPlanningLine.TestField("Contrato Task No.");

        JobPlanningLineInvoice.SetRange("Contrato No.", JobPlanningLine."Contrato No.");
        JobPlanningLineInvoice.SetRange("Contrato Task No.", JobPlanningLine."Contrato Task No.");
        JobPlanningLineInvoice.SetRange("Contrato Planning Line No.", JobPlanningLine."Line No.");
        if JobPlanningLineInvoice.Count = 1 then begin
            JobPlanningLineInvoice.FindFirst();
            OpenSalesInvoice(JobPlanningLineInvoice);
        end else
            PAGE.RunModal(PAGE::"Contrato Invoices", JobPlanningLineInvoice);
    end;

    procedure OpenSalesInvoice(JobPlanningLineInvoice: Record "Contrato Planning Line Invoice")
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOpenSalesInvoice(JobPlanningLineInvoice, IsHandled);
        if IsHandled then
            exit;

        case JobPlanningLineInvoice."Document Type" of
            JobPlanningLineInvoice."Document Type"::Invoice:
                begin
                    SalesHeader.Get(SalesHeader."Document Type"::Invoice, JobPlanningLineInvoice."Document No.");
                    PAGE.RunModal(PAGE::"Sales Invoice", SalesHeader);
                end;
            JobPlanningLineInvoice."Document Type"::"Credit Memo":
                begin
                    SalesHeader.Get(SalesHeader."Document Type"::"Credit Memo", JobPlanningLineInvoice."Document No.");
                    PAGE.RunModal(PAGE::"Sales Credit Memo", SalesHeader);
                end;
            JobPlanningLineInvoice."Document Type"::"Posted Invoice":
                begin
                    if not SalesInvHeader.Get(JobPlanningLineInvoice."Document No.") then
                        Error(Text012, SalesInvHeader.TableCaption(), JobPlanningLineInvoice."Document No.");
                    PAGE.RunModal(PAGE::"Posted Sales Invoice", SalesInvHeader);
                end;
            JobPlanningLineInvoice."Document Type"::"Posted Credit Memo":
                begin
                    if not SalesCrMemoHeader.Get(JobPlanningLineInvoice."Document No.") then
                        Error(Text012, SalesCrMemoHeader.TableCaption(), JobPlanningLineInvoice."Document No.");
                    PAGE.RunModal(PAGE::"Posted Sales Credit Memo", SalesCrMemoHeader);
                end;
        end;

        OnAfterOpenSalesInvoice(JobPlanningLineInvoice);
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

    local procedure UpdateSalesHeader(var SalesHeader: Record "Sales Header"; JobPlanningLine: Record "Contrato Planning Line")
    var
        JobTask: Record "Contrato Task";
        FormatAddress: Codeunit "Format Address";
    begin
        JobTask.Get(JobPlanningLine."Contrato No.", JobPlanningLine."Contrato Task No.");
        SalesHeader."Bill-to Contact No." := JobTask."Bill-to Contact No.";
        SalesHeader."Bill-to Contact" := JobTask."Bill-to Contact";
        SalesHeader."Bill-to Name" := JobTask."Bill-to Name";
        SalesHeader."Bill-to Name 2" := JobTask."Bill-to Name 2";
        SalesHeader."Bill-to Address" := JobTask."Bill-to Address";
        SalesHeader."Bill-to Address 2" := JobTask."Bill-to Address 2";
        SalesHeader."Bill-to City" := JobTask."Bill-to City";
        SalesHeader."Bill-to Post Code" := JobTask."Bill-to Post Code";
        SalesHeader."Bill-to Country/Region Code" := JobTask."Bill-to Country/Region Code";

        SalesHeader."Sell-to Contact No." := JobTask."Sell-to Contact No.";
        SalesHeader."Sell-to Contact" := JobTask."Sell-to Contact";
        SalesHeader."Sell-to Customer Name" := JobTask."Sell-to Customer Name";
        SalesHeader."Sell-to Customer Name 2" := JobTask."Sell-to Customer Name 2";
        SalesHeader."Sell-to Address" := JobTask."Sell-to Address";
        SalesHeader."Sell-to Address 2" := JobTask."Sell-to Address 2";
        SalesHeader."Sell-to City" := JobTask."Sell-to City";
        SalesHeader."Sell-to Post Code" := JobTask."Sell-to Post Code";
        SalesHeader."Sell-to Country/Region Code" := JobTask."Sell-to Country/Region Code";

        if JobTask."Ship-to Code" <> '' then
            SalesHeader.Validate("Ship-to Code", JobTask."Ship-to Code")
        else
            if SalesHeader."Ship-to Code" = '' then begin
                SalesHeader."Ship-to Contact" := JobTask."Ship-to Contact";
                SalesHeader."Ship-to Name" := JobTask."Ship-to Name";
                SalesHeader."Ship-to Address" := JobTask."Ship-to Address";
                SalesHeader."Ship-to Address 2" := JobTask."Ship-to Address 2";
                SalesHeader."Ship-to City" := JobTask."Ship-to City";
                SalesHeader."Ship-to Post Code" := JobTask."Ship-to Post Code";
                SalesHeader."Ship-to Country/Region Code" := JobTask."Ship-to Country/Region Code";
                if FormatAddress.UseCounty(SalesHeader."Ship-to Country/Region Code") then
                    SalesHeader."Ship-to County" := JobTask."Ship-to County";
            end;

        if FormatAddress.UseCounty(SalesHeader."Bill-to Country/Region Code") then
            SalesHeader."Bill-to County" := JobTask."Bill-to County";
        if FormatAddress.UseCounty(SalesHeader."Sell-to Country/Region Code") then
            SalesHeader."Sell-to County" := JobTask."Sell-to County";
    end;

    local procedure TestSalesHeader(var SalesHeader: Record "Sales Header"; var Contrato: Record Contrato; JobPlanningLine: Record "Contrato Planning Line")
    var
        JobTask: Record "Contrato Task";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestSalesHeader(SalesHeader, Contrato, IsHandled, JobPlanningLine);
        if IsHandled then
            exit;

        Contrato.Get(JobPlanningLine."Contrato No.");
        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then begin
            SalesHeader.TestField("Bill-to Customer No.", Contrato."Bill-to Customer No.");
            SalesHeader.TestField("Sell-to Customer No.", Contrato."Sell-to Customer No.");
        end else begin
            JobTask.Get(JobPlanningLine."Contrato No.", JobPlanningLine."Contrato Task No.");
            SalesHeader.TestField("Bill-to Customer No.", JobTask."Bill-to Customer No.");
            SalesHeader.TestField("Sell-to Customer No.", JobTask."Sell-to Customer No.");
        end;

        if Contrato."Currency Code" <> '' then
            SalesHeader.TestField("Currency Code", Contrato."Currency Code")
        else
            if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
                SalesHeader.TestField("Currency Code", Contrato."Invoice Currency Code")
            else
                SalesHeader.TestField("Currency Code", JobTask."Invoice Currency Code");
        OnAfterTestSalesHeader(SalesHeader, Contrato, JobPlanningLine);
    end;

    local procedure TestExchangeRate(var JobPlanningLine: Record "Contrato Planning Line"; PostingDate: Date)
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        OnBeforeTestExchangeRate(JobPlanningLine, PostingDate, UpdateExchangeRates, CurrencyExchangeRate);

        if JobPlanningLine."Currency Code" <> '' then
            if (CurrencyExchangeRate.ExchangeRate(PostingDate, JobPlanningLine."Currency Code") <> JobPlanningLine."Currency Factor")
            then begin
                if not UpdateExchangeRates then
                    UpdateExchangeRates := Confirm(Text010, true);

                if UpdateExchangeRates then begin
                    JobPlanningLine."Currency Date" := PostingDate;
                    JobPlanningLine."Document Date" := PostingDate;
                    JobPlanningLine.Validate("Currency Date");
                    JobPlanningLine."Last Date Modified" := Today;
                    JobPlanningLine."User ID" := CopyStr(UserId(), 1, MaxStrLen(JobPlanningLine."User ID"));
                    JobPlanningLine.Modify(true);
                end else
                    Error('');
            end;
    end;

    local procedure GetLedgEntryDimSetID(JobPlanningLine: Record "Contrato Planning Line"): Integer
    var
        ResLedgEntry: Record "Res. Ledger Entry";
        ItemLedgEntry: Record "Item Ledger Entry";
        GLEntry: Record "G/L Entry";
    begin
        if JobPlanningLine."Ledger Entry No." = 0 then
            exit(0);

        case JobPlanningLine."Ledger Entry Type" of
            JobPlanningLine."Ledger Entry Type"::Resource:
                begin
                    ResLedgEntry.Get(JobPlanningLine."Ledger Entry No.");
                    exit(ResLedgEntry."Dimension Set ID");
                end;
            JobPlanningLine."Ledger Entry Type"::Item:
                begin
                    ItemLedgEntry.Get(JobPlanningLine."Ledger Entry No.");
                    exit(ItemLedgEntry."Dimension Set ID");
                end;
            JobPlanningLine."Ledger Entry Type"::"G/L Account":
                begin
                    GLEntry.Get(JobPlanningLine."Ledger Entry No.");
                    exit(GLEntry."Dimension Set ID");
                end;
            else
                exit(0);
        end;
    end;

    local procedure GetJobLedgEntryDimSetID(JobPlanningLine: Record "Contrato Planning Line"): Integer
    var
        JobLedgerEntry: Record "Contrato Ledger Entry";
    begin
        if JobPlanningLine."Contrato Ledger Entry No." = 0 then
            exit(0);

        if JobLedgerEntry.Get(JobPlanningLine."Contrato Ledger Entry No.") then
            exit(JobLedgerEntry."Dimension Set ID");

        exit(0);
    end;

    local procedure UpdateSalesLineDimension(var SalesLine: Record "Sales Line"; JobPlanningLine: Record "Contrato Planning Line")
    var
        SourceCodeSetup: Record "Source Code Setup";
        DimMgt: Codeunit DimensionManagement;
        DimSetIDArr: array[10] of Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateSalesLineDimension(SalesLine, JobPlanningLine, IsHandled);
        if not IsHandled then begin
            SourceCodeSetup.Get();
            DimSetIDArr[1] := SalesLine."Dimension Set ID";
            DimSetIDArr[2] :=
                DimMgt.CreateDimSetFromJobTaskDim(
                SalesLine."Job No.", SalesLine."Job Task No.", SalesLine."Shortcut Dimension 1 Code", SalesLine."Shortcut Dimension 2 Code");
            DimSetIDArr[3] := GetLedgEntryDimSetID(JobPlanningLine);
            DimSetIDArr[4] := GetJobLedgEntryDimSetID(JobPlanningLine);
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

    local procedure IsJobInvCurrencyDependingOnBillingMethod(Contrato: Record Contrato; var JobPlanningLineSource: Record "Contrato Planning Line"): Boolean
    var
        JobTask: Record "Contrato Task";
    begin
        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
            exit(Contrato."Invoice Currency Code" <> '')
        else begin
            JobTask.Get(JobPlanningLineSource."Contrato No.", JobPlanningLineSource."Contrato Task No.");
            exit(JobTask."Invoice Currency Code" <> '');
        end;
    end;

    local procedure IsJobInvCurrencyDependingOnBillingMethod(Contrato: Record Contrato; JobTask: Record "Contrato Task"): Boolean
    begin
        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
            exit(Contrato."Invoice Currency Code" <> '')
        else
            exit(JobTask."Invoice Currency Code" <> '');
    end;

    local procedure TestIfBillToCustomerExistOnJobOrJobTask(Contrato: Record Contrato; JobTask: Record "Contrato Task")
    begin
        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
            Contrato.TestField("Bill-to Customer No.")
        else
            JobTask.TestField("Bill-to Customer No.");
    end;

    local procedure ReturnBillToCustomerNoDependingOnTaskBillingMethod(Contrato: Record Contrato; JobTask2: Record "Contrato Task"): Code[20]
    var
        JobTask: Record "Contrato Task";
    begin
        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
            exit(Contrato."Bill-to Customer No.")
        else
            if JobTask.Get(TempJobPlanningLine."Contrato No.", TempJobPlanningLine."Contrato Task No.") then
                exit(JobTask."Bill-to Customer No.")
            else
                exit(JobTask2."Bill-to Customer No.");
    end;

    local procedure ReturnJobDataDependingOnTaskBillingMethod(Contrato: Record Contrato; JobPlanningLine: Record "Contrato Planning Line"; FieldName: Text): Text[35]
    var
        JobTask: Record "Contrato Task";
        DataTypeMgt: Codeunit "Data Type Management";
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then begin
            RecRef.GetTable(Contrato);
            if DataTypeMgt.FindFieldByName(RecRef, FldRef, FieldName) then
                exit(FldRef.Value());
        end else begin
            JobTask.Get(JobPlanningLine."Contrato No.", JobPlanningLine."Contrato Task No.");
            RecRef.GetTable(JobTask);
            if DataTypeMgt.FindFieldByName(RecRef, FldRef, FieldName) then
                exit(FldRef.Value());
        end;
    end;

#if not CLEAN24
    local procedure CheckJobPlanningLineIsNegative(JobPlanningLine: Record "Contrato Planning Line")
    var
        IsHandled: Boolean;
    begin
        OnBeforeCheckJobPlanningLineIsNegative(JobPlanningLine, IsHandled);
        if IsHandled then
            exit;
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateSalesInvoiceLines(SalesHeader: Record "Sales Header"; NewInvoice: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateSalesHeader(Contrato: Record Contrato; PostingDate: Date; var SalesHeader2: Record "Sales Header"; var JobPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateSalesLine(var JobPlanningLine: Record "Contrato Planning Line"; var SalesHeader: Record "Sales Header"; var SalesHeader2: Record "Sales Header"; var JobInvCurrency: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateSalesLine(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; Contrato: Record Contrato; var JobPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateSalesHeader(var SalesHeader: Record "Sales Header"; Contrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateNewInvoice(var JobTask: Record "Contrato Task"; InvoicePerTask: Boolean; var OldJobNo: Code[20]; var OldJobTaskNo: Code[20]; LastJobTask: Boolean; var NewInvoice: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateSalesInvoiceLines(var JobPlanningLine: Record "Contrato Planning Line"; InvoiceNo: Code[20]; NewInvoice: Boolean; PostingDate: Date; CreditMemo: Boolean; var NoOfSalesLinesCreated: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateSalesInvoiceJobTask(var JobTask2: Record "Contrato Task"; PostingDate: Date; InvoicePerTask: Boolean; var NoOfInvoices: Integer; var OldJobNo: Code[20]; var OldJobTaskNo: Code[20]; LastJobTask: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteSalesLine(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetInvoiceNo(var JobPlanningLine: Record "Contrato Planning Line"; Done: Boolean; NewInvoice: Boolean; PostingDate: Date; var InvoiceNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetCrMemoNo(var JobPlanningLine: Record "Contrato Planning Line"; Done: Boolean; NewInvoice: Boolean; PostingDate: Date; var InvoiceNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertSalesHeader(var SalesHeader: Record "Sales Header"; Contrato: Record Contrato; JobPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifySalesHeader(var SalesHeader: Record "Sales Header"; Contrato: Record Contrato; JobPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertSalesLine(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; Contrato: Record Contrato; JobPlanningLine: Record "Contrato Planning Line"; JobInvCurrency: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifySalesLine(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; Contrato: Record Contrato; JobPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenSalesInvoice(var JobPlanningLineInvoice: Record "Contrato Planning Line Invoice"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestSalesHeader(var SalesHeader: Record "Sales Header"; Contrato: Record Contrato; var IsHandled: Boolean; var JobPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTransferLine(var JobPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateSalesHeader(var SalesHeader: Record "Sales Header"; Contrato: Record Contrato; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOpenSalesInvoice(var JobPlanningLineInvoice: Record "Contrato Planning Line Invoice")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestSalesHeader(var SalesHeader: Record "Sales Header"; Contrato: Record Contrato; JobPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckJobBillToCustomer(JobPlanningLineSource: Record "Contrato Planning Line"; Contrato: Record Contrato; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindInvoices(var TempJobPlanningLineInvoice: Record "Contrato Planning Line Invoice" temporary; JobNo: Code[20]; JobTaskNo: Code[20]; JobPlanningLineNo: Integer; DetailLevel: Option; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowMessageLinesTransferred(var JobPlanningLine: Record "Contrato Planning Line"; CrMemo: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestExchangeRate(var JobPlanningLine: Record "Contrato Planning Line"; PostingDate: Date; var UpdateExchangeRates: Boolean; var CurrencyExchangeRate: Record "Currency Exchange Rate")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestTransferred(var JobPlanningLine: Record "Contrato Planning Line"; SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesLineOnAfterCalcShouldUpdateCurrencyFactor(var JobPlanningLine: Record "Contrato Planning Line"; var Contrato: Record Contrato; var SalesHeader: Record "Sales Header"; var SalesHeader2: Record "Sales Header"; var JobInvCurrency: Boolean; var ShouldUpdateCurrencyFactor: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesHeaderOnBeforeUpdateSalesHeader(var SalesHeader: Record "Sales Header"; var Contrato: Record Contrato; var IsHandled: Boolean; JobPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesLineOnBeforeSalesCheckIfAnyExtText(var JobPlanningLine: Record "Contrato Planning Line"; var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesLineOnBeforeValidateSalesLineNo(var JobPlanningLine: Record "Contrato Planning Line"; var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesLineOnAfterSalesLineModify(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; Contrato: Record Contrato; JobPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceLinesOnAfterValidateJobPlanningLine(var JobPlanningLine: Record "Contrato Planning Line"; var LastError: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceLinesOnBeforeJobPlanningLineFindSet(var JobPlanningLine: Record "Contrato Planning Line"; InvoiceNo: Code[20]; NewInvoice: Boolean; PostingDate: Date; CreditMemo: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceLinesOnBeforeJobPlanningLineModify(var JobPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceLinesOnBeforeCreateSalesLine(var JobPlanningLine: Record "Contrato Planning Line"; SalesHeader: Record "Sales Header"; SalesHeader2: Record "Sales Header"; NewInvoice: Boolean; var NoOfSalesLinesCreated: Integer)
    begin
    end;
#if not CLEAN23
    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceLinesOnBeforeGetCustomer(JobPlanningLine: Record "Contrato Planning Line"; var Customer: Record Customer; var IsHandled: Boolean)
    begin
    end;
#endif
    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceLinesOnBeforeTestJob(var Contrato: Record Contrato)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceJobTaskOnAfterLinesCreated(var SalesHeader: Record "Sales Header"; var Contrato: Record Contrato; InvoicePerTask: Boolean; LastJobTask: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceJobTaskOnBeforeTempJobPlanningLineFind(var JobTask: Record "Contrato Task"; var SalesHeader: Record "Sales Header"; InvoicePerTask: Boolean; var TempJobPlanningLine: Record "Contrato Planning Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceJobTaskOnBeforeCreateSalesLine(var JobPlanningLine: Record "Contrato Planning Line"; SalesHeader: Record "Sales Header"; SalesHeader2: Record "Sales Header"; var NoOfSalesLinesCreated: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceJobTaskTestJob(var Contrato: Record Contrato; var JobPlanningLine: Record "Contrato Planning Line"; PostingDate: Date)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteSalesLineOnBeforeJobPlanningLineModify(var JobPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceJobTaskOnBeforeJobPlanningLineInvoiceInsert(var JobPlanningLineInvoice: Record "Contrato Planning Line Invoice")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceOnBeforeRunReport(var JobPlanningLine: Record "Contrato Planning Line"; var Done: Boolean; var NewInvoice: Boolean; var PostingDate: Date; var InvoiceNo: Code[20]; var IsHandled: Boolean; CrMemo: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindInvoicesOnBeforeTempJobPlanningLineInvoiceInsert(var TempJobPlanningLineInvoice: Record "Contrato Planning Line Invoice"; JobPlanningLineInvoice: Record "Contrato Planning Line Invoice")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindInvoicesOnBeforeTempJobPlanningLineInvoiceModify(var TempJobPlanningLineInvoice: Record "Contrato Planning Line Invoice"; JobPlanningLineInvoice: Record "Contrato Planning Line Invoice")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesHeaderOnBeforeCheckBillToCustomerNo(var SalesHeader: Record "Sales Header"; Contrato: Record Contrato; JobPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceLinesOnBeforeJobPlanningLineCopy(Contrato: Record Contrato; var JobPlanningLineSource: Record "Contrato Planning Line"; PostingDate: Date)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateSalesLineDimension(var SalesLine: Record "Sales Line"; JobPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

#if not CLEAN24
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckJobPlanningLineIsNegative(JobPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceLinesOnAfterSetJobInvCurrency(Contrato: Record Contrato; var JobInvCurrency: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesLineOnBeforeValidateCurrencyCode(var IsHandled: Boolean; SalesLine: Record "Sales Line"; JobPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceLinesOnAfterSetSalesDocumentType(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeGetJobPlanningLineInvoices(JobPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesInvoiceJobTaskOnAfterJobPlanningLineSetFilters(var JobPlanningLine: Record "Contrato Planning Line"; var JobTask2: Record "Contrato Task")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesLineOnBeforeCheckPricesIncludingVATAndSetJobInformation(var SalesLine: Record "Sales Line"; JobPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteSalesLineOnBeforeGetJobPlanningLine(JobPlanningLineInvoice: Record "Contrato Planning Line Invoice")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetCustomerNo(var Contrato: Record Contrato; var JobPlanningLine: Record "Contrato Planning Line"; SellToCustomerNo: Boolean; var CustomerNo: Code[20])
    begin
    end;
}

