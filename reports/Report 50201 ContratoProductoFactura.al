report 50201 "Contrato Producto Factura"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Local/contratos/contrato/Reports/ContratoCostSuggestedBilling.rdlc';
    Caption = 'Contrato Producto Factura';
    AdditionalSearchTerms = 'Contrato Producto Factura';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Contrato Producto"; "Contrato Producto")
        {

            RequestFilterFields = "Código";

        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {



            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
        //ContratoFilter := Contrato.GetFilters();
    end;

    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
        ContratoPlanningLine: Record "Contrato Planning Line";
        ContratoLedgerEntry: Record "Contrato Ledger Entry";
        ContratoFilter: Text;
        SuggestedBilling: Decimal;
        Text000: Label 'Total for %1 %2 %3';
        ContractPrice: Decimal;
        UsagePrice: Decimal;
        InvoicedPrice: Decimal;
        Contrato_Cost_Suggested_BillingCaptionLbl: Label 'contrato Cost Suggested Billing';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        ContractPriceCaptionLbl: Label 'Billable Price';
        UsagePriceCaptionLbl: Label 'Usage Amount';
        InvoicedPriceCaptionLbl: Label 'Invoiced Amount';
        SuggestedBillingCaptionLbl: Label 'Suggested Billing';
        Report_TotalCaptionLbl: Label 'Report Total';
        Código: Code[20];
}

