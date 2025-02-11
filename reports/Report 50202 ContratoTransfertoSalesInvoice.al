report 50202 "ContratoTransfertoSalesInvoice"
{
    Caption = 'Contrato Transfer to Sales Invoice';
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(CreateNewInvoice; NewInvoice)
                    {
                        ApplicationArea = All;
                        Caption = 'Create New Invoice';
                        ToolTip = 'Specifies if the batch Contrato creates a new sales invoice.';

                        trigger OnValidate()
                        begin
                            if NewInvoice then begin
                                InvoiceNo := '';
                                if PostingDate = 0D then
                                    PostingDate := WorkDate();
                                if DocumentDate = 0D then
                                    DocumentDate := WorkDate();
                                InvoicePostingDate := 0D;
                            end;
                        end;
                    }
                    field(PostingDate; PostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the posting date for the document.';

                        trigger OnValidate()
                        var
                            SalesReceivablesSetup: Record "Sales & Receivables Setup";
                        begin
                            if PostingDate = 0D then
                                NewInvoice := false;
                            SalesReceivablesSetup.SetLoadFields("Link Doc. Date To Posting Date");
                            SalesReceivablesSetup.GetRecordOnce();
                            if SalesReceivablesSetup."Link Doc. Date To Posting Date" then
                                DocumentDate := PostingDate;
                        end;
                    }
                    field("Document Date"; DocumentDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Document Date';
                        ToolTip = 'Specifies the document date.';

                        trigger OnValidate()
                        begin
                            if DocumentDate = 0D then
                                NewInvoice := false;
                        end;
                    }
                    field(AppendToSalesInvoiceNo; InvoiceNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Append to Sales Invoice No.';
                        ToolTip = 'Specifies the number of the sales invoice that you want to append the lines to if you did not select the Create New Sales Invoice field.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            Clear(SalesHeader);
                            SalesHeader.FilterGroup := 2;
                            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
                            SalesHeader.SetRange("Bill-to Customer No.", BillToCustomerNo);
                            if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"Multiple customers" then begin
                                SalesHeader.SetRange("Sell-to Customer No.", SellToCustomerNo);
                                SalesHeader.SetRange("Currency Code", CurrencyCode);
                            end;
                            SalesHeader.FilterGroup := 0;
                            if PAGE.RunModal(0, SalesHeader) = ACTION::LookupOK then
                                InvoiceNo := SalesHeader."No.";
                            if InvoiceNo <> '' then begin
                                SalesHeader.Get(SalesHeader."Document Type"::Invoice, InvoiceNo);
                                InvoicePostingDate := SalesHeader."Posting Date";
                                NewInvoice := false;
                                PostingDate := 0D;
                                DocumentDate := 0D;
                            end;
                            if InvoiceNo = '' then
                                InitReport();
                        end;

                        trigger OnValidate()
                        begin
                            if InvoiceNo <> '' then begin
                                SalesHeader.Get(SalesHeader."Document Type"::Invoice, InvoiceNo);
                                InvoicePostingDate := SalesHeader."Posting Date";
                                NewInvoice := false;
                                PostingDate := 0D;
                                DocumentDate := 0D;
                            end;
                            if InvoiceNo = '' then
                                InitReport();
                        end;
                    }
                    field(InvoicePostingDate; InvoicePostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Invoice Posting Date';
                        Editable = false;
                        ToolTip = 'Specifies, if you filled in the Append to Sales Invoice No. field, the posting date of the invoice.';

                        trigger OnValidate()
                        begin
                            if PostingDate = 0D then
                                NewInvoice := false;
                        end;
                    }
                    field(GrupoFacturar; GrupoFacturarRequest)
                    {
                        ApplicationArea = All;
                        Caption = 'Grupo a facturar';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            InitReport();
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        Done := false;
    end;

    trigger OnPostReport()
    begin
        Done := true;
    end;

    var
        SalesHeader: Record "Sales Header";
        BillToCustomerNo, SellToCustomerNo, CurrencyCode : Code[20];
        PostingDate: Date;
        DocumentDate: Date;
        InvoicePostingDate: Date;
        Done: Boolean;
        GrupoFacturarRequest: Enum "Grupo Facturar";

    protected var
        Contrato: Record Contrato;
        InvoiceNo: Code[20];
        NewInvoice: Boolean;
#if not CLEAN23
    [Obsolete('Replaced by GetInvoiceNo(var Done2: Boolean; var NewInvoice2: Boolean; var PostingDate2: Date; var DocumentDate2: Date; var InvoiceNo2: Code[20])', '23.0')]
    procedure GetInvoiceNo(var Done2: Boolean; var NewInvoice2: Boolean; var PostingDate2: Date; var InvoiceNo2: Code[20])
    var
        DocumentDate2: date;
    begin
        GetInvoiceNo(Done2, NewInvoice2, PostingDate2, DocumentDate2, InvoiceNo2);
    end;
#endif
    procedure GetInvoiceNo(var Done2: Boolean; var NewInvoice2: Boolean; var PostingDate2: Date; var DocumentDate2: Date; var InvoiceNo2: Code[20])
    begin
        Done2 := Done;
        NewInvoice2 := NewInvoice;
        PostingDate2 := PostingDate;
        InvoiceNo2 := InvoiceNo;
        DocumentDate2 := DocumentDate;
    end;

    procedure InitReport()
    begin
        PostingDate := WorkDate();
        DocumentDate := WorkDate();
        NewInvoice := true;
        InvoiceNo := '';
        InvoicePostingDate := 0D;
    end;

    procedure SetCustomer(ContratoNo: Code[20])
    begin
        Contrato.Get(ContratoNo);
    end;

    procedure SetCustomer(ContratoPlanningLine: Record "Contrato Planning Line")
    var
        ContratoTask: Record "Contrato Task";
        IsHandled: Boolean;
    begin
        Contrato.Get(ContratoPlanningLine."Contrato No.");
        IsHandled := false;
        OnBeforeSetCustomer(ContratoPlanningLine, BillToCustomerNo, SellToCustomerNo, CurrencyCode, IsHandled);
        if IsHandled then
            exit;

        BillToCustomerNo := Contrato."Bill-to Customer No.";

        if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"One customer" then
            exit;

        ContratoTask.SetLoadFields("Bill-to Customer No.", "Sell-to Customer No.", "Invoice Currency Code");
        if ContratoTask.Get(ContratoPlanningLine."Contrato No.", ContratoPlanningLine."Contrato Task No.") then begin
            BillToCustomerNo := ContratoTask."Bill-to Customer No.";
            SellToCustomerNo := ContratoTask."Sell-to Customer No.";
            CurrencyCode := ContratoTask."Invoice Currency Code";
        end;
    end;

    procedure SetPostingDate(PostingDate2: Date)
    begin
        PostingDate := PostingDate2;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetCustomer(ContratoPlanningLine: Record "Contrato Planning Line"; var BillToCustomerNo: Code[20]; var SellToCustomerNo: Code[20]; var CurrencyCode: Code[20]; var IsHandled: Boolean)
    begin
    end;
}

