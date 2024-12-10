report 50204 "Contrato Create Sales Invoice"
{
    AdditionalSearchTerms = 'Contrato Create Sales Invoice';
    ApplicationArea = All;
    Caption = 'Contrato Create Sales Invoice';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("Contrato Task"; "Contrato Task")
        {
            DataItemTableView = sorting("Contrato No.", "Contrato Task No.");
            RequestFilterFields = "Contrato No.", "Contrato Task No.", "Planning Date Filter";

            trigger OnAfterGetRecord()
            var
                Contrato: Record "Contrato";
                IsHandled: Boolean;
            begin
                if Contrato.Get("Contrato Task"."Contrato No.") then
                    if Contrato."Task Billing Method" = Contrato."Task Billing Method"::"Multiple customers" then
                        InvoicePerTask := true
                    else
                        if ContratoChoice = ContratoChoice::Contrato then
                            InvoicePerTask := false;

                IsHandled := false;
                OnBeforeContratoTaskOnAfterGetRecord("Contrato Task", IsHandled);
                if not IsHandled then
                    ContratoCreateInvoice.CreateSalesInvoiceContratoTask(
                      "Contrato Task", PostingDate, DocumentDate, InvoicePerTask, NoOfInvoices, OldContratoNo, OldJTNo, false);
            end;

            trigger OnPostDataItem()
            begin
                ContratoCreateInvoice.CreateSalesInvoiceContratoTask(
                  "Contrato Task", PostingDate, DocumentDate, InvoicePerTask, NoOfInvoices, OldContratoNo, OldJTNo, true);
            end;

            trigger OnPreDataItem()
            begin
                NoOfInvoices := 0;
                OldContratoNo := '';
                OldJTNo := '';
            end;
        }
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
                    field(PostingDate; PostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the posting date for the document.';

                        trigger OnValidate()
                        var
                            SalesReceivablesSetup: Record "Sales & Receivables Setup";
                        begin
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
                    }
                    field(ContratoChoice; ContratoChoice)
                    {
                        ApplicationArea = All;
                        Caption = 'Create Invoice per';
                        OptionCaption = 'Contrato,Contrato Task';
                        ToolTip = 'Specifies, if you select the Contrato Task option, that you want to create one invoice per Contrato task rather than the one invoice per Contrato that is created by default.';
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
            PostingDate := WorkDate();
            DocumentDate := WorkDate();
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        OnBeforeOnOnInitReport(ContratoChoice);
    end;

    trigger OnPostReport()
    begin
        OnBeforePostReport();

        ContratoCalcBatches.EndCreateInvoice(NoOfInvoices);

        OnAfterPostReport(NoOfInvoices);
    end;

    trigger OnPreReport()
    begin
        ContratoCalcBatches.BatchError(PostingDate, Text000);
        InvoicePerTask := ContratoChoice = ContratoChoice::"Contrato Task";
        ContratoCreateInvoice.DeleteSalesInvoiceBuffer();

        OnAfterPreReport();
    end;

    var
        ContratoCreateInvoice: Codeunit "Contrato Create-Invoice";
        ContratoCalcBatches: Codeunit "Contrato Calculate Batches";
        NoOfInvoices: Integer;
        InvoicePerTask: Boolean;
        OldContratoNo: Code[20];
        OldJTNo: Code[20];
        Text000: Label 'A', Comment = 'A';
        GrupoFacturarRequest: Enum "Grupo Facturar";

    protected var
        ContratoChoice: Option Contrato,"Contrato Task";
        PostingDate, DocumentDate : Date;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostReport(NoOfInvoices: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPreReport()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnOnInitReport(var ContratoChoice: Option Contrato,"Contrato Task")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeContratoTaskOnAfterGetRecord(ContratoTask: Record "Contrato Task"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostReport()
    begin
    end;
}

