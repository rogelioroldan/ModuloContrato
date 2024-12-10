report 50215 "Contratos per Customer"
{
    AdditionalSearchTerms = 'Contratos per Customer';
    DefaultLayout = RDLC;
    RDLCLayout = './Contratos/Contrato/Reports/ContratosperCustomer.rdlc';
    ApplicationArea = All;
    Caption = 'Contratos per Customer';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = sorting("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Customer Posting Group";
            column(TodayFormatted; Format(Today))
            {
            }
            column(CompanyName; COMPANYPROPERTY.DisplayName())
            {
            }
            column(CustCustFilter; TableCaption + ': ' + CustFilter)
            {
            }
            column(CustFilter; CustFilter)
            {
            }
            column(ContratoFilterCaptn_Cust; Contrato.TableCaption + ': ' + ContratoFilter)
            {
            }
            column(ContratoFilter_Cust; ContratoFilter)
            {
            }
            column(No_Cust; "No.")
            {
            }
            column(Name_Cust; Name)
            {
            }
            column(Amt6; Amt[6])
            {
            }
            column(Amt4; Amt[4])
            {
            }
            column(Amt3; Amt[3])
            {
            }
            column(Amt5; Amt[5])
            {
            }
            column(Amt2; Amt[2])
            {
            }
            column(Amt1; Amt[1])
            {
            }
            column(ContratosperCustCaption; ContratosperCustCaptionLbl)
            {
            }
            column(PageCaption; PageCaptionLbl)
            {
            }
            column(AllAmtAreInLCYCaption; AllAmtAreInLCYCaptionLbl)
            {
            }
            column(ContratoNoCaption; ContratoNoCaptionLbl)
            {
            }
            column(EndingDateCaption; EndingDateCaptionLbl)
            {
            }
            column(ScheduleLineAmtCaption; ScheduleLineAmtCaptionLbl)
            {
            }
            column(UsageLineAmtCaption; UsageLineAmtCaptionLbl)
            {
            }
            column(CompletionCaption; CompletionCaptionLbl)
            {
            }
            column(ContractInvLineAmtCaption; ContractInvLineAmtCaptionLbl)
            {
            }
            column(ContractLineAmtCaption; ContractLineAmtCaptionLbl)
            {
            }
            column(InvoicingCaption; InvoicingCaptionLbl)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }
            dataitem(Contrato; Contrato)
            {
                DataItemLink = "Bill-to Customer No." = field("No.");
                DataItemTableView = sorting("Bill-to Customer No.");
                RequestFilterFields = "No.", "Posting Date Filter", "Planning Date Filter", Blocked;
                column(Endingdate_Contrato; Format("Ending Date"))
                {
                }
                column(No_Contrato; "No.")
                {
                }
                column(Desc_Contrato; Description)
                {
                    IncludeCaption = true;
                }
                column(TableCaptnCustNo; TotalForTxt + ' ' + Customer.TableCaption + ' ' + Customer."No.")
                {
                }
                column(BilltoCustomerNo_Contrato; "Bill-to Customer No.")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    ContratoCalculateStatistics.RepContratoCustomer(Contrato, Amt);
                end;

                trigger OnPreDataItem()
                begin
                    Clear(Amt[1]);
                    Clear(Amt[2]);
                    Clear(Amt[3]);
                    Clear(Amt[4]);
                end;
            }

            trigger OnPreDataItem()
            begin
                Clear(Amt);
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
    var
        FormatDocument: Codeunit "Format Document";
    begin
        CustFilter := FormatDocument.GetRecordFiltersWithCaptions(Customer);
        ContratoFilter := Contrato.GetFilters();
    end;

    var
        ContratoCalculateStatistics: Codeunit "Contrato Calculate Statistics";
        CustFilter: Text;
        ContratoFilter: Text;
        Amt: array[8] of Decimal;
        TotalForTxt: Label 'Total for';
        ContratosperCustCaptionLbl: Label 'Contratos per Customer';
        PageCaptionLbl: Label 'Page';
        AllAmtAreInLCYCaptionLbl: Label 'All amounts are in LCY';
        ContratoNoCaptionLbl: Label 'Contrato No.';
        EndingDateCaptionLbl: Label 'Ending Date';
        ScheduleLineAmtCaptionLbl: Label 'Budget Line Amount';
        UsageLineAmtCaptionLbl: Label 'Usage Line Amount';
        CompletionCaptionLbl: Label 'Completion %';
        ContractInvLineAmtCaptionLbl: Label 'Billable Invoice Line Amount';
        ContractLineAmtCaptionLbl: Label 'Billable Line Amount';
        InvoicingCaptionLbl: Label 'Invoicing %';
        TotalCaptionLbl: Label 'Total';
}

