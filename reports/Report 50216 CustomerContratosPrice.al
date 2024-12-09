report 50216 "Customer Contratos (Price)"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Local/Sales/Reports/CustomerContratosPrice.rdlc';
    ApplicationArea = Contratos;
    Caption = 'Customer Contratos (Price)';
    AdditionalSearchTerms = 'Customer Contratos (Price)';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Contrato; Contrato)
        {
            DataItemTableView = sorting("Bill-to Customer No.") where(Status = const(Open), "Bill-to Customer No." = filter(<> ''));
            RequestFilterFields = "Bill-to Customer No.", "Starting Date", "Ending Date";
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
            column(BudgetOptionText; BudgetOptionText)
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
            column(BudgetedPrice; BudgetedPrice)
            {
            }
            column(UsagePrice; UsagePrice)
            {
            }
            column(Percent_Completion_; "Percent Completion"())
            {
                DecimalPlaces = 1 : 1;
            }
            column(InvoicedPrice; InvoicedPrice)
            {
            }
            column(Percent_Invoiced_; "Percent Invoiced"())
            {
                DecimalPlaces = 1 : 1;
            }
            column(Total_for_____Customer_TABLECAPTION_________Customer_FIELDCAPTION__No_____________Bill_to_Customer_No__; 'Total for ' + Customer.TableCaption + ' ' + Customer.FieldCaption("No.") + ' ' + "Bill-to Customer No.")
            {
            }
            column(BudgetedPrice_Control20; BudgetedPrice)
            {
            }
            column(UsagePrice_Control21; UsagePrice)
            {
            }
            column(Percent_Completion__Control22; "Percent Completion"())
            {
                DecimalPlaces = 1 : 1;
            }
            column(InvoicedPrice_Control29; InvoicedPrice)
            {
            }
            column(Percent_Invoiced__Control31; "Percent Invoiced"())
            {
                DecimalPlaces = 1 : 1;
            }
            column(BudgetedPrice_Control25; BudgetedPrice)
            {
            }
            column(UsagePrice_Control26; UsagePrice)
            {
            }
            column(InvoicedPrice_Control30; InvoicedPrice)
            {
            }
            column(Contrato_Bill_to_Customer_No_; "Bill-to Customer No.")
            {
            }
            column(Customer_Contratos___PriceCaption; Customer_Contratos___PriceCaptionLbl)
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
            column(BudgetedPriceCaption; BudgetedPriceCaptionLbl)
            {
            }
            column(UsagePriceCaption; UsagePriceCaptionLbl)
            {
            }
            column(Percent_Completion_Caption; Percent_Completion_CaptionLbl)
            {
            }
            column(InvoicedPriceCaption; InvoicedPriceCaptionLbl)
            {
            }
            column(Percent_Invoiced_Caption; Percent_Invoiced_CaptionLbl)
            {
            }
            column(Report_TotalCaption; Report_TotalCaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                BudgetedPrice := 0;
                UsagePrice := 0;
                InvoicedPrice := 0;

                ContratoPlanningLine.Reset();
                if BudgetAmountsPer = BudgetAmountsPer::Contract then begin
                    ContratoPlanningLine.SetCurrentKey("Contrato No.", "Contrato Task No.", "Contract Line", "Planning Date");
                    ContratoPlanningLine.SetRange("Contract Line", true);
                end else begin
                    ContratoPlanningLine.SetCurrentKey("Contrato No.", "Contrato Task No.", "Schedule Line", "Planning Date");
                    ContratoPlanningLine.SetRange("Schedule Line", true);
                end;
                ContratoPlanningLine.SetRange("Contrato No.", "No.");
                CopyFilter("Planning Date Filter", ContratoPlanningLine."Planning Date");
                ContratoPlanningLine.CalcSums("Total Price (LCY)");
                BudgetedPrice := ContratoPlanningLine."Total Price (LCY)";

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
                if not Customer.Get("Bill-to Customer No.") then
                    Customer.Init();
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(BudgetAmountsPer; BudgetAmountsPer)
                    {
                        ApplicationArea = Contratos;
                        Caption = 'Budget Amounts Per';
                        OptionCaption = 'Budget,Billable';
                        ToolTip = 'Specifies if the budget amounts must be based on budgets or billables.';
                    }
                }
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
        ContratoFilter := Contrato.GetFilters();
        if BudgetAmountsPer = BudgetAmountsPer::Schedule then
            BudgetOptionText := Text001
        else
            BudgetOptionText := Text002;
    end;

    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
        ContratoPlanningLine: Record "Contrato Planning Line";
        ContratoLedgerEntry: Record "Contrato Ledger Entry";
        ContratoFilter: Text;
        BudgetedPrice: Decimal;
        UsagePrice: Decimal;
        InvoicedPrice: Decimal;
        BudgetAmountsPer: Option Schedule,Contract;
        BudgetOptionText: Text[50];
        Text001: Label 'Budgeted Amounts are per the Budget';
        Text002: Label 'Budgeted Amounts are per the Contract';
        Customer_Contratos___PriceCaptionLbl: Label 'Customer Contratos - Price';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        BudgetedPriceCaptionLbl: Label 'Budgeted Price';
        UsagePriceCaptionLbl: Label 'Usage Price';
        Percent_Completion_CaptionLbl: Label 'Percent Completion';
        InvoicedPriceCaptionLbl: Label 'Invoiced Price';
        Percent_Invoiced_CaptionLbl: Label 'Percent Invoiced';
        Report_TotalCaptionLbl: Label 'Report Total';

    procedure "Percent Completion"(): Decimal
    begin
        if BudgetedPrice = 0 then
            exit(0);

        exit(100 * UsagePrice / BudgetedPrice);
    end;

    procedure "Percent Invoiced"(): Decimal
    begin
        if UsagePrice = 0 then
            exit(0);

        exit(100 * InvoicedPrice / UsagePrice);
    end;
}

