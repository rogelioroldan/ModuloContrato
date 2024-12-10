report 50214 "Customer Contratos (Cost)"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Local/Sales/Reports/CustomerContratosCost.rdlc';
    ApplicationArea = All;
    Caption = 'Customer Contratos (Cost)';
    AdditionalSearchTerms = 'Customer Contratos (Cost)';
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
            column(ScheduledCost; ScheduledCost)
            {
            }
            column(UsageCost; UsageCost)
            {
            }
            column(Percent_Completion_; "Percent Completion"())
            {
                DecimalPlaces = 1 : 1;
            }
            column(Total_for_____Customer_TABLECAPTION_________Customer_FIELDCAPTION__No_____________Bill_to_Customer_No__; 'Total for ' + Customer.TableCaption + ' ' + Customer.FieldCaption("No.") + ' ' + "Bill-to Customer No.")
            {
            }
            column(ScheduledCost_Control20; ScheduledCost)
            {
            }
            column(UsageCost_Control21; UsageCost)
            {
            }
            column(Percent_Completion__Control22; "Percent Completion"())
            {
                DecimalPlaces = 1 : 1;
            }
            column(ScheduledCost_Control25; ScheduledCost)
            {
            }
            column(UsageCost_Control26; UsageCost)
            {
            }
            column(Contrato_Bill_to_Customer_No_; "Bill-to Customer No.")
            {
            }
            column(Customer_Contratos___CostCaption; Customer_Contratos___CostCaptionLbl)
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
            column(ScheduledCostCaption; ScheduledCostCaptionLbl)
            {
            }
            column(UsageCostCaption; UsageCostCaptionLbl)
            {
            }
            column(Percent_Completion_Caption; Percent_Completion_CaptionLbl)
            {
            }
            column(Report_TotalCaption; Report_TotalCaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                ScheduledCost := 0;
                UsageCost := 0;

                ContratoPlanningLine.Reset();
                ContratoPlanningLine.SetCurrentKey("Contrato No.", "Contrato Task No.", "Schedule Line", "Planning Date");
                ContratoPlanningLine.SetRange("Contrato No.", "No.");
                CopyFilter("Planning Date Filter", ContratoPlanningLine."Planning Date");
                ContratoPlanningLine.SetRange("Schedule Line", true);
                ContratoPlanningLine.CalcSums("Total Cost (LCY)");
                ScheduledCost := ContratoPlanningLine."Total Cost (LCY)";

                ContratoLedgerEntry.Reset();
                ContratoLedgerEntry.SetCurrentKey("Contrato No.", "Contrato Task No.", "Entry Type", "Posting Date");
                ContratoLedgerEntry.SetRange("Contrato No.", "No.");
                CopyFilter("Posting Date Filter", ContratoLedgerEntry."Posting Date");
                ContratoLedgerEntry.SetRange("Entry Type", ContratoLedgerEntry."Entry Type"::Usage);
                ContratoLedgerEntry.CalcSums("Total Cost (LCY)");
                UsageCost := ContratoLedgerEntry."Total Cost (LCY)";
                if not Customer.Get("Bill-to Customer No.") then
                    Customer.Init();
            end;

            trigger OnPreDataItem()
            begin
                Clear(ScheduledCost);
                Clear(UsageCost);
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
        ScheduledCost: Decimal;
        UsageCost: Decimal;
        Customer_Contratos___CostCaptionLbl: Label 'Customer Contratos - Cost';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        ScheduledCostCaptionLbl: Label 'Budget Cost';
        UsageCostCaptionLbl: Label 'Actual Cost';
        Percent_Completion_CaptionLbl: Label 'Percent Completion';
        Report_TotalCaptionLbl: Label 'Report Total';

    procedure "Percent Completion"(): Decimal
    begin
        if ScheduledCost = 0 then
            exit(0);

        exit(100 * UsageCost / ScheduledCost);
    end;
}

