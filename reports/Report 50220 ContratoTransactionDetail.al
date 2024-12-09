report 50220 "Contrato - Transaction Detail"
{
    AdditionalSearchTerms = 'Contrato - Transaction Detail';
    DefaultLayout = RDLC;
    RDLCLayout = './Contratos/Contrato/Reports/ContratoTransactionDetail.rdlc';
    ApplicationArea = Contratos;
    Caption = 'Contrato Task - Transaction Detail';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Contrato; Contrato)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";
            column(No_Contrato; "No.")
            {
            }
            column(ContratoTotalCost1; ContratoTotalCost[1])
            {
            }
            column(ContratoTotalCost2; ContratoTotalCost[2])
            {
            }
            column(ContratoTotalPrice1; ContratoTotalPrice[1])
            {
            }
            column(ContratoTotalPrice2; ContratoTotalPrice[2])
            {
            }
            column(ContratoTotalLineDiscAmount1; ContratoTotalLineDiscAmount[1])
            {
            }
            column(ContratoTotalLineDiscAmount2; ContratoTotalLineDiscAmount[2])
            {
            }
            column(ContratoTotalLineAmount1; ContratoTotalLineAmount[1])
            {
            }
            column(ContratoTotalLineAmount2; ContratoTotalLineAmount[2])
            {
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                column(CompanyName; COMPANYPROPERTY.DisplayName())
                {
                }
                column(TodayFormatted; Format(Today, 0, 4))
                {
                }
                column(ContratoFilterCaption; Contrato.TableCaption + ': ' + ContratoFilter)
                {
                }
                column(ContratoFilter; ContratoFilter)
                {
                }
                column(ContratoLedgEntryFilterCaption; "Contrato Ledger Entry".TableCaption + ': ' + ContratoLedgEntryFilter)
                {
                }
                column(ContratoLedgEntryFilter; ContratoLedgEntryFilter)
                {
                }
                column(Description_Contrato; Contrato.Description)
                {
                }
                column(CurrencyField0; ContratoCalculateBatches.GetCurrencyCode(Contrato, 0, CurrencyFieldReq))
                {
                }
                column(CurrencyField1; ContratoCalculateBatches.GetCurrencyCode(Contrato, 1, CurrencyFieldReq))
                {
                }
                column(CurrencyField2; ContratoCalculateBatches.GetCurrencyCode(Contrato, 2, CurrencyFieldReq))
                {
                }
                column(CurrencyField3; ContratoCalculateBatches.GetCurrencyCode(Contrato, 3, CurrencyFieldReq))
                {
                }
                column(ContratoTransactionDetailCaption; ContratoTransactionDetailCaptionLbl)
                {
                }
                column(PageNoCaption; PageNoCaptionLbl)
                {
                }
                column(ContratoNoCaption; ContratoNoCaptionLbl)
                {
                }
                column(PostingDateCaption; PostingDateCaptionLbl)
                {
                }
                column(ContratoLedgEntryEntryTypeCaption; "Contrato Ledger Entry".FieldCaption("Entry Type"))
                {
                }
                column(ContratoLedgEntryDocNoCaption; "Contrato Ledger Entry".FieldCaption("Document No."))
                {
                }
                column(ContratoLedgEntryTypeCaption; "Contrato Ledger Entry".FieldCaption(Type))
                {
                }
                column(ContratoLedgEntryNoCaption; "Contrato Ledger Entry".FieldCaption("No."))
                {
                }
                column(ContratoLedgEntryQtyCaption; "Contrato Ledger Entry".FieldCaption(Quantity))
                {
                }
                column(ContratoLedgEntryUOMCodeCaption; "Contrato Ledger Entry".FieldCaption("Unit of Measure Code"))
                {
                }
                column(ContratoLedgEntryEntryNoCaption; "Contrato Ledger Entry".FieldCaption("Entry No."))
                {
                }
            }
            dataitem("Contrato Task"; "Contrato Task")
            {
                DataItemLink = "Contrato No." = field("No.");
                DataItemTableView = sorting("Contrato No.", "Contrato Task No.");
                PrintOnlyIfDetail = true;
                column(ContratoTaskNo_ContratoTask; "Contrato Task No.")
                {
                }
                column(Description_ContratoTask; Description)
                {
                }
                column(CurrencyField; CurrencyFieldReq)
                {
                }
                column(TotalCostTotal1; TotalCostTotal[1])
                {
                    AutoFormatType = 1;
                }
                column(TotalCostTotal2; TotalCostTotal[2])
                {
                    AutoFormatType = 1;
                }
                column(TotalPriceTotal1; TotalPriceTotal[1])
                {
                    AutoFormatType = 1;
                }
                column(TotalPriceTotal2; TotalPriceTotal[2])
                {
                    AutoFormatType = 1;
                }
                column(TotalLineDiscAmt1; TotalLineDiscAmount[1])
                {
                    AutoFormatType = 1;
                }
                column(TotalLineDiscAmt2; TotalLineDiscAmount[2])
                {
                    AutoFormatType = 1;
                }
                column(TotalLineAmt1; TotalLineAmount[1])
                {
                    AutoFormatType = 1;
                }
                column(ContratoNo_ContratoTask; "Contrato No.")
                {
                }
                column(ContratoTaskContratoTaskNoCaption; FieldCaption("Contrato Task No."))
                {
                }
                column(TotalUsageCaption; TotalUsageCaptionLbl)
                {
                }
                column(TotalSaleCaption; TotalSaleCaptionLbl)
                {
                }
                dataitem("Contrato Ledger Entry"; "Contrato Ledger Entry")
                {
                    DataItemLink = "Contrato No." = field("Contrato No."), "Contrato Task No." = field("Contrato Task No.");
                    DataItemTableView = sorting("Contrato No.", "Contrato Task No.", "Entry Type", "Posting Date");
                    RequestFilterFields = "Posting Date";
                    column(EntryNo_ContratoLedgEntry; "Entry No.")
                    {
                    }
                    column(LineAmtLCY_ContratoLedgEntry; "Line Amount (LCY)")
                    {
                    }
                    column(LineDiscAmtLCY_ContratoLedgEntry; "Line Discount Amount (LCY)")
                    {
                    }
                    column(TotalPriceLCY_ContratoLedgEntry; "Total Price (LCY)")
                    {
                    }
                    column(TotalCostLCY_ContratoLedgEntry; "Total Cost (LCY)")
                    {
                    }
                    column(UOMCode_ContratoLedgEntry; "Unit of Measure Code")
                    {
                    }
                    column(Quantity_ContratoLedgEntry; Quantity)
                    {
                    }
                    column(No_ContratoLedgEntry; "No.")
                    {
                    }
                    column(Type_ContratoLedgEntry; Type)
                    {
                    }
                    column(DocNo_ContratoLedgEntry; "Document No.")
                    {
                    }
                    column(EntryType_ContratoLedgEntry; "Entry Type")
                    {
                    }
                    column(PostDate_ContratoLedgEntry; Format("Posting Date"))
                    {
                    }
                    column(LineAmt_ContratoLedgEntry; "Line Amount")
                    {
                    }
                    column(LineDiscAmt_ContratoLedgEntry; "Line Discount Amount")
                    {
                    }
                    column(TotalPrice_ContratoLedgEntry; "Total Price")
                    {
                    }
                    column(TotalCost_ContratoLedgEntry; "Total Cost")
                    {
                    }
                    column(TotalCostTotal11; TotalCostTotal[1])
                    {
                        AutoFormatType = 1;
                    }
                    column(TotalCostTotal21; TotalCostTotal[2])
                    {
                        AutoFormatType = 1;
                    }
                    column(TotalPriceTotal11; TotalPriceTotal[1])
                    {
                        AutoFormatType = 1;
                    }
                    column(TotalPriceTotal21; TotalPriceTotal[2])
                    {
                        AutoFormatType = 1;
                    }
                    column(TotalLineDiscAmt11; TotalLineDiscAmount[1])
                    {
                        AutoFormatType = 1;
                    }
                    column(TotalLineDiscAmt21; TotalLineDiscAmount[2])
                    {
                        AutoFormatType = 1;
                    }
                    column(TotalLineAmt11; TotalLineAmount[1])
                    {
                        AutoFormatType = 1;
                    }
                    column(ContratoNo_ContratoLedgEntry; "Contrato No.")
                    {
                    }
                    column(ContratoTaskNo_ContratoLedgEntry; "Contrato Task No.")
                    {
                    }
                    column(UsageCaption; UsageCaptionLbl)
                    {
                    }
                    column(SalesCaption; SalesCaptionLbl)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if "Entry Type" = "Entry Type"::Usage then
                            I := 1
                        else
                            I := 2;
                        if CurrencyFieldReq = CurrencyFieldReq::"Local Currency" then begin
                            TotalCostTotal[I] += "Total Cost (LCY)";
                            TotalPriceTotal[I] += "Total Price (LCY)";
                            TotalLineDiscAmount[I] += "Line Discount Amount (LCY)";
                            TotalLineAmount[I] += "Line Amount (LCY)";
                            ContratoTotalCost[I] += "Total Cost (LCY)";
                            ContratoTotalLineAmount[I] += "Line Amount (LCY)";
                            ContratoTotalLineDiscAmount[I] += "Line Discount Amount (LCY)";
                            ContratoTotalPrice[I] += "Total Price (LCY)";
                        end else begin
                            TotalCostTotal[I] += "Total Cost";
                            TotalPriceTotal[I] += "Total Price";
                            TotalLineDiscAmount[I] += "Line Discount Amount";
                            TotalLineAmount[I] += "Line Amount";
                            ContratoTotalCost[I] += "Total Cost";
                            ContratoTotalLineAmount[I] += "Line Amount";
                            ContratoTotalLineDiscAmount[I] += "Line Discount Amount";
                            ContratoTotalPrice[I] += "Total Price";
                        end;
                    end;

                    trigger OnPreDataItem()
                    begin
                        Clear(TotalCostTotal);
                        Clear(TotalPriceTotal);
                        Clear(TotalLineDiscAmount);
                        Clear(TotalLineAmount);
                    end;
                }

                trigger OnPreDataItem()
                begin
                    Clear(TotalCostTotal);
                    Clear(TotalPriceTotal);
                    Clear(TotalLineDiscAmount);
                    Clear(TotalLineAmount);
                end;
            }

            trigger OnAfterGetRecord()
            var
                ContratoLedgEntry: Record "Contrato Ledger Entry";
            begin
                Clear(ContratoTotalCost);
                Clear(ContratoTotalPrice);
                Clear(ContratoTotalLineAmount);
                Clear(ContratoTotalLineDiscAmount);

                ContratoLedgEntry.SetCurrentKey("Contrato No.", "Entry Type");
                ContratoLedgEntry.SetRange("Contrato No.", "No.");
                ContratoLedgEntry.SetRange("Entry Type", ContratoLedgEntry."Entry Type"::Usage);
                if ContratoLedgEntry.IsEmpty() then
                    CurrReport.Skip();
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
                    field(CurrencyField; CurrencyFieldReq)
                    {
                        ApplicationArea = Contratos;
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
        ContratoLedgEntryFilter := "Contrato Ledger Entry".GetFilters();
    end;

    var
        ContratoCalculateBatches: Codeunit "Contrato Calculate Batches";
        TotalCostTotal: array[2] of Decimal;
        TotalPriceTotal: array[2] of Decimal;
        TotalLineDiscAmount: array[2] of Decimal;
        TotalLineAmount: array[2] of Decimal;
        ContratoTotalCost: array[2] of Decimal;
        ContratoTotalPrice: array[2] of Decimal;
        ContratoTotalLineDiscAmount: array[2] of Decimal;
        ContratoTotalLineAmount: array[2] of Decimal;
        ContratoFilter: Text;
        ContratoLedgEntryFilter: Text;
        I: Integer;
        ContratoTransactionDetailCaptionLbl: Label 'Contrato - Transaction Detail';
        PageNoCaptionLbl: Label 'Page';
        ContratoNoCaptionLbl: Label 'Contrato No.';
        PostingDateCaptionLbl: Label 'Posting Date';
        TotalUsageCaptionLbl: Label 'Total Usage';
        TotalSaleCaptionLbl: Label 'Total Sale';
        UsageCaptionLbl: Label 'Usage';
        SalesCaptionLbl: Label 'Sales';

    protected var
        CurrencyFieldReq: Option "Local Currency","Foreign Currency";

    procedure InitializeRequest(NewCurrencyField: Option "Local Currency","Foreign Currency")
    begin
        CurrencyFieldReq := NewCurrencyField;
    end;
}

