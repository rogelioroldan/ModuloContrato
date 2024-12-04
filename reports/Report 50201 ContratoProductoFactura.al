report 50201 "Contrato Producto Factura"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Local/Projects/Project/Reports/JobCostSuggestedBilling.rdlc';
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
        //JobFilter := Job.GetFilters();
    end;

    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
        JobPlanningLine: Record "Job Planning Line";
        JobLedgerEntry: Record "Job Ledger Entry";
        JobFilter: Text;
        SuggestedBilling: Decimal;
        Text000: Label 'Total for %1 %2 %3';
        ContractPrice: Decimal;
        UsagePrice: Decimal;
        InvoicedPrice: Decimal;
        Job_Cost_Suggested_BillingCaptionLbl: Label 'Project Cost Suggested Billing';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        ContractPriceCaptionLbl: Label 'Billable Price';
        UsagePriceCaptionLbl: Label 'Usage Amount';
        InvoicedPriceCaptionLbl: Label 'Invoiced Amount';
        SuggestedBillingCaptionLbl: Label 'Suggested Billing';
        Report_TotalCaptionLbl: Label 'Report Total';
        Código: Code[20];
}

