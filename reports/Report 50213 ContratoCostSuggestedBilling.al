report 50213 "ContratoCostSuggestedBilling"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Local/Contratos/Contrato/Reports/ContratoCostSuggestedBilling.rdlc';
    Caption = 'Contrato Cost Suggested Billing';
    AdditionalSearchTerms = 'Contrato Cost Suggested Billing';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Contrato; Contrato)
        {
            DataItemTableView = sorting("Bill-to Customer No.") where(Status = const(Open), "Bill-to Customer No." = filter(<> ''));
            RequestFilterFields = "Bill-to Customer No.", "Posting Date Filter", "Planning Date Filter";
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(TIME; Time)
            {
            }
            column(CompanyInformation_Name; CompanyInformation.Name)
            {
            }
            column(USERID; UserId)
            {
            }
            column(Contrato_TABLECAPTION__________ContratoFilter; Contrato.TableCaption + ': ' + ContratoFilter)
            {
            }
            column(ContratoFilter; ContratoFilter)
            {
            }
            column(Customer_TABLECAPTION_________Customer_FIELDCAPTION__No_____________Bill_to_Customer_No__; Customer.TableCaption + ' ' + Customer.FieldCaption("No.") + ' ' + "Bill-to Customer No.")
            {
            }
            column(Customer_Name; Customer.Name)
            {
            }
            column(Contrato__Bill_to_Customer_No__; Contrato."Bill-to Customer No.")
            {
            }
            column(Contrato__No__; "No.")
            {
            }
            column(Contrato_Description; Description)
            {
            }
            column(Contrato__Starting_Date_; "Starting Date")
            {
            }
            column(Contrato__Ending_Date_; "Ending Date")
            {
            }
            column(ContractPrice; ContractPrice)
            {
            }
            column(UsagePrice; UsagePrice)
            {
            }
            column(InvoicedPrice; InvoicedPrice)
            {
            }
            column(SuggestedBilling; SuggestedBilling)
            {
            }
            column(STRSUBSTNO_Text000_Customer_TABLECAPTION_Customer_FIELDCAPTION__No_____Bill_to_Customer_No___; StrSubstNo(Text000, Customer.TableCaption(), Customer.FieldCaption("No."), "Bill-to Customer No."))
            {
            }
            column(ContractPrice_Control20; ContractPrice)
            {
            }
            column(UsagePrice_Control21; UsagePrice)
            {
            }
            column(InvoicedPrice_Control29; InvoicedPrice)
            {
            }
            column(SuggestedBilling_Control31; SuggestedBilling)
            {
            }
            column(ContractPrice_Control25; ContractPrice)
            {
            }
            column(UsagePrice_Control26; UsagePrice)
            {
            }
            column(InvoicedPrice_Control30; InvoicedPrice)
            {
            }
            column(SuggestedBilling_Control14; SuggestedBilling)
            {
            }
            column(Contrato_Cost_Suggested_BillingCaption; Contrato_Cost_Suggested_BillingCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Contrato__No__Caption; FieldCaption("No."))
            {
            }
            column(Contrato_DescriptionCaption; FieldCaption(Description))
            {
            }
            column(Contrato__Starting_Date_Caption; FieldCaption("Starting Date"))
            {
            }
            column(Contrato__Ending_Date_Caption; FieldCaption("Ending Date"))
            {
            }
            column(ContractPriceCaption; ContractPriceCaptionLbl)
            {
            }
            column(UsagePriceCaption; UsagePriceCaptionLbl)
            {
            }
            column(InvoicedPriceCaption; InvoicedPriceCaptionLbl)
            {
            }
            column(SuggestedBillingCaption; SuggestedBillingCaptionLbl)
            {
            }
            column(Report_TotalCaption; Report_TotalCaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                ContractPrice := 0;
                UsagePrice := 0;
                InvoicedPrice := 0;
                SuggestedBilling := 0;

                ContratoPlanningLine.Reset();
                ContratoPlanningLine.SetCurrentKey("Contrato No.", "Contrato Task No.", "Contract Line", "Planning Date");
                ContratoPlanningLine.SetRange("Contract Line", true);
                ContratoPlanningLine.SetRange("Contrato No.", "No.");
                CopyFilter("Planning Date Filter", ContratoPlanningLine."Planning Date");
                ContratoPlanningLine.CalcSums("Total Price (LCY)");
                ContractPrice := ContratoPlanningLine."Total Price (LCY)";

                ContratoLedgerEntry.Reset();
                ContratoLedgerEntry.SetCurrentKey("Contrato No.", "Contrato Task No.", "Entry Type", "Posting Date");
                ContratoLedgerEntry.SetRange("Contrato No.", "No.");
                CopyFilter("Posting Date Filter", ContratoLedgerEntry."Posting Date");
                if ContratoLedgerEntry.FindSet() then
                    repeat
                        if ContratoLedgerEntry."Entry Type" = ContratoLedgerEntry."Entry Type"::Sale then
                            InvoicedPrice := InvoicedPrice - ContratoLedgerEntry."Total Price (LCY)"
                        else
                            UsagePrice := UsagePrice + ContratoLedgerEntry."Total Price (LCY)";
                    until ContratoLedgerEntry.Next() = 0;

                if UsagePrice > InvoicedPrice then
                    SuggestedBilling := UsagePrice - InvoicedPrice;

                if not Customer.Get("Bill-to Customer No.") then
                    Customer.Init();
            end;

            trigger OnPreDataItem()
            begin
                Clear(ContractPrice);
                Clear(UsagePrice);
                Clear(InvoicedPrice);
                Clear(SuggestedBilling);
            end;
        }
    }

    requestpage
    {

        layout
        {
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
        ContratoFilter := Contrato.GetFilters();
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
        Contrato_Cost_Suggested_BillingCaptionLbl: Label 'Contrato Cost Suggested Billing';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        ContractPriceCaptionLbl: Label 'Billable Price';
        UsagePriceCaptionLbl: Label 'Usage Amount';
        InvoicedPriceCaptionLbl: Label 'Invoiced Amount';
        SuggestedBillingCaptionLbl: Label 'Suggested Billing';
        Report_TotalCaptionLbl: Label 'Report Total';
}

