report 50212 "Contrato Suggested Billing"
{
    AdditionalSearchTerms = 'Contrato Suggested Billing';
    DefaultLayout = RDLC;
    RDLCLayout = './Contratos/Contrato/Reports/ContratoSuggestedBilling.rdlc';
    ApplicationArea = All;
    Caption = 'Contrato Suggested Billing';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Contrato; Contrato)
        {
            RequestFilterFields = "No.", "Bill-to Customer No.", "Posting Date Filter", "Planning Date Filter";
            column(TodayFormatted; Format(Today, 0, 4))
            {
            }
            column(CompanyName; COMPANYPROPERTY.DisplayName())
            {
            }
            column(ContratoTableCaptionContratoFilter; TableCaption + ': ' + ContratoFilter)
            {
            }
            column(ContratoFilter; ContratoFilter)
            {
            }
            column(TableCaptionContratoTaskFilter; "Contrato Task".TableCaption + ': ' + ContratoTaskFilter)
            {
            }
            column(ContratoTaskFilter; ContratoTaskFilter)
            {
            }
            column(EmptyString; '')
            {
            }
            column(ContratoNo; "No.")
            {
            }
            column(CurrReportPageNoCaption; CurrReportPageNoCaptionLbl)
            {
            }
            column(ContratoSuggestedBillCaption; ContratoSuggestedBillCaptionLbl)
            {
            }
            column(ContratoTaskNoCaption; ContratoTaskNoCaptionLbl)
            {
            }
            column(TotalContractCaption; TotalContractCaptionLbl)
            {
            }
            column(CostCaption; CostCaptionLbl)
            {
            }
            column(SalesCaption; SalesCaptionLbl)
            {
            }
            column(ContractInvoicedCaption; ContractInvoicedCaptionLbl)
            {
            }
            column(SuggestedBillingCaption; SuggestedBillingCaptionLbl)
            {
            }
            column(CurrencyCodeCaption; FieldCaption("Currency Code"))
            {
            }
            dataitem("Contrato Task"; "Contrato Task")
            {
                DataItemLink = "Contrato No." = field("No.");
                DataItemTableView = sorting("Contrato No.", "Contrato Task No.") where("Contrato Task Type" = const(Posting));
                RequestFilterFields = "Contrato Task No.";
                column(ContratoDescription; Contrato.Description)
                {
                }
                column(CustTableCaption; Cust.TableCaption + ' :')
                {
                }
                column(Cust2Name; Cust2.Name)
                {
                }
                column(Cust2No; Cust2."No.")
                {
                }
                column(ContratoTableCaption; Contrato.TableCaption + ' :')
                {
                }
                column(ContratoTaskContratoTaskNo; "Contrato Task No.")
                {
                }
                column(ContratoTaskContratoTaskDescription; Description)
                {
                }
                column(Amt1; Amt[1])
                {
                }
                column(Amt2; Amt[2])
                {
                }
                column(Amt3; Amt[3])
                {
                }
                column(Amt4; Amt[4])
                {
                }
                column(Amt5; Amt[5])
                {
                }
                column(Amt6; Amt[6])
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(ContratoCalcStatistics);
                    ContratoCalcStatistics.ReportSuggBilling(Contrato, "Contrato Task", Amt, CurrencyField);
                    PrintContratoTask := false;

                    for I := 1 to 6 do
                        if Amt[I] <> 0 then
                            PrintContratoTask := true;
                    if not PrintContratoTask then
                        CurrReport.Skip();
                    for I := 1 to 6 do
                        TotalAmt[I] := TotalAmt[I] + Amt[I];
                end;
            }
            dataitem(ContratoTaskTotal; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                column(ContratoTableCaptionContratoNo; TotalForTxt + ' ' + Contrato.TableCaption + ' ' + Contrato."No.")
                {
                }
                column(TotalAmt4; TotalAmt[4])
                {
                }
                column(TotalAmt5; TotalAmt[5])
                {
                }
                column(TotalAmt6; TotalAmt[6])
                {
                }
                column(TotalAmt1; TotalAmt[1])
                {
                }
                column(TotalAmt2; TotalAmt[2])
                {
                }
                column(TotalAmt3; TotalAmt[3])
                {
                }
                column(CurrencyCode; CurrencyCode)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    PrintContratoTask := false;

                    for I := 1 to 6 do
                        if TotalAmt[I] <> 0 then
                            PrintContratoTask := true;
                    if not PrintContratoTask then
                        CurrReport.Skip();

                    Clear(ContratoBuffer);
                    CurrencyCode := '';
                    if CurrencyField[1] = CurrencyField[1] ::"Foreign Currency" then
                        CurrencyCode := Contrato."Currency Code";
                    if CurrencyCode = '' then
                        CurrencyCode := GLSetup."LCY Code";
                    ContratoBuffer[1]."Account No. 1" := Contrato."Bill-to Customer No.";
                    ContratoBuffer[1]."Account No. 2" := CurrencyCode;
                    ContratoBuffer[1]."Amount 1" := TotalAmt[1];
                    ContratoBuffer[1]."Amount 2" := TotalAmt[2];
                    ContratoBuffer[1]."Amount 3" := TotalAmt[3];
                    ContratoBuffer[1]."Amount 4" := TotalAmt[4];
                    ContratoBuffer[2] := ContratoBuffer[1];
                    if ContratoBuffer[2].Find() then begin
                        ContratoBuffer[2]."Amount 1" := ContratoBuffer[2]."Amount 1" + ContratoBuffer[1]."Amount 1";
                        ContratoBuffer[2]."Amount 2" := ContratoBuffer[2]."Amount 2" + ContratoBuffer[1]."Amount 2";
                        ContratoBuffer[2]."Amount 3" := ContratoBuffer[2]."Amount 3" + ContratoBuffer[1]."Amount 3";
                        ContratoBuffer[2]."Amount 4" := ContratoBuffer[2]."Amount 4" + ContratoBuffer[1]."Amount 4";
                        ContratoBuffer[2].Modify();
                    end else
                        ContratoBuffer[1].Insert();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                for I := 1 to 8 do
                    TotalAmt[I] := 0;
                Clear(Cust2);
                if "Bill-to Customer No." = '' then
                    CurrReport.Skip();
                if Cust2.Get("Bill-to Customer No.") then;
            end;
        }
        dataitem(TotalBilling; "Integer")
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
            column(TotalForCustTableCaption; TotalForTxt + ' ' + Cust.TableCaption())
            {
            }
            column(DescriptionCaption; DescriptionCaptionLbl)
            {
            }
            column(CustomerNoCaption; CustomerNoCaptionLbl)
            {
            }
        }
        dataitem(TotalCustomer; "Integer")
        {
            DataItemTableView = sorting(Number) where(Number = filter(1 ..));
            column(CustTotalAmt1; TotalAmt[1])
            {
            }
            column(CustTotalAmt2; TotalAmt[2])
            {
            }
            column(CustTotalAmt3; TotalAmt[3])
            {
            }
            column(CustTotalAmt4; TotalAmt[4])
            {
            }
            column(CustTotalAmt5; TotalAmt[5])
            {
            }
            column(CustTotalAmt6; TotalAmt[6])
            {
            }
            column(CustName; Cust.Name)
            {
            }
            column(CustNo; Cust."No.")
            {
            }
            column(CurrencyCode1; CurrencyCode)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then begin
                    if not ContratoBuffer[1].Find('-') then
                        CurrReport.Break();
                end else
                    if ContratoBuffer[1].Next() = 0 then
                        CurrReport.Break();
                Clear(Cust);
                Clear(TotalAmt);
                if not Cust.Get(ContratoBuffer[1]."Account No. 1") then
                    CurrReport.Skip();
                TotalAmt[1] := ContratoBuffer[1]."Amount 1";
                TotalAmt[2] := ContratoBuffer[1]."Amount 2";
                TotalAmt[3] := ContratoBuffer[1]."Amount 3";
                TotalAmt[4] := ContratoBuffer[1]."Amount 4";
                TotalAmt[5] := TotalAmt[1] - TotalAmt[3];
                TotalAmt[6] := TotalAmt[2] - TotalAmt[4];
                CurrencyCode := ContratoBuffer[1]."Account No. 2"
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
                    field("CurrencyField[1]"; CurrencyField[1])
                    {
                        ApplicationArea = All;
                        Caption = 'Currency';
                        OptionCaption = 'Local Currency,Foreign Currency';
                        ToolTip = 'Specifies the currency that amounts are shown in.';
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
        ContratoFilter := Contrato.GetFilters();
        ContratoTaskFilter := "Contrato Task".GetFilters();
        CurrencyField[2] := CurrencyField[1];
        CurrencyField[3] := CurrencyField[1];
        ContratoBuffer[1].DeleteAll();
        GLSetup.Get();
    end;

    var
        GLSetup: Record "General Ledger Setup";
        Cust: Record Customer;
        Cust2: Record Customer;
        ContratoBuffer: array[2] of Record "Contrato Buffer" temporary;
        ContratoCalcStatistics: Codeunit "Contrato Calculate Statistics";
        Amt: array[8] of Decimal;
        TotalAmt: array[8] of Decimal;
        CurrencyField: array[8] of Option "Local Currency","Foreign Currency";
        ContratoFilter: Text;
        ContratoTaskFilter: Text;
        PrintContratoTask: Boolean;
        I: Integer;
        TotalForTxt: Label 'Total for';
        CurrencyCode: Code[20];
        CurrReportPageNoCaptionLbl: Label 'Page';
        ContratoSuggestedBillCaptionLbl: Label 'Contrato Suggested Billing';
        ContratoTaskNoCaptionLbl: Label 'Contrato Task No.';
        TotalContractCaptionLbl: Label 'Total Billable';
        CostCaptionLbl: Label 'Cost';
        SalesCaptionLbl: Label 'Sales';
        ContractInvoicedCaptionLbl: Label 'Billable (Invoiced) ';
        SuggestedBillingCaptionLbl: Label 'Suggested Billing';
        DescriptionCaptionLbl: Label 'Description';
        CustomerNoCaptionLbl: Label 'Customer No.';

    procedure InitializeRequest(NewCurrencyField: Option "Local Currency","Foreign Currency")
    begin
        CurrencyField[1] := NewCurrencyField;
    end;
}

