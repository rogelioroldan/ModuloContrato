report 50211 "Contrato - Planning Lines"
{
    AdditionalSearchTerms = 'Contrato - Planning Lines';
    DefaultLayout = RDLC;
    RDLCLayout = './Contratos/Contrato/Reports/ContratoPlanningLines.rdlc';
    ApplicationArea = All;
    Caption = 'Contrato - Planning Lines';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Contrato; Contrato)
        {
            DataItemTableView = sorting("No.");
            PrintOnlyIfDetail = true;
            column(No_Contrato; StrSubstNo('%1 %2 %3 %4', TableCaption(), FieldCaption("No."), "No.", Description))
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
                column(ContratoTaskCaption; "Contrato Task".TableCaption + ': ' + JTFilter)
                {
                }
                column(ShowJTFilter; JTFilter)
                {
                }
                column(Desc_Contrato; Contrato.Description)
                {
                }
                column(CurrCodeContrato0Fld; ContratoCalcBatches.GetCurrencyCode(Contrato, 0, CurrencyField))
                {
                }
                column(CurrCodeContrato2Fld; ContratoCalcBatches.GetCurrencyCode(Contrato, 2, CurrencyField))
                {
                }
                column(CurrCodeContrato3Fld; ContratoCalcBatches.GetCurrencyCode(Contrato, 3, CurrencyField))
                {
                }
                column(ContratoPlanningLinesCaption; ContratoPlanningLinesCaptionLbl)
                {
                }
                column(CurrReportPageNoCaption; CurrReportPageNoCaptionLbl)
                {
                }
                column(ContratoPlannLinePlannDtCptn; ContratoPlannLinePlannDtCptnLbl)
                {
                }
                column(LineTypeCaption; LineTypeCaptionLbl)
                {
                }
            }
            dataitem("Contrato Task"; "Contrato Task")
            {
                DataItemLink = "Contrato No." = field("No.");
                DataItemTableView = sorting("Contrato No.", "Contrato Task No.");
                PrintOnlyIfDetail = true;
                RequestFilterFields = "Contrato No.", "Contrato Task No.";
                column(ContratoTaskNo_ContratoTask; "Contrato Task No.")
                {
                }
                column(Desc_ContratoTask; Description)
                {
                }
                column(TotalCost1_ContratoTask; TotalCost[1])
                {
                }
                column(TotalCost2_ContratoTask; TotalCost[2])
                {
                }
                column(FooterTotalCost1_ContratoTask; FooterTotalCost1)
                {
                }
                column(FooterTotalCost2_ContratoTask; FooterTotalCost2)
                {
                }
                column(FooterLineDisAmt1_ContratoTask; FooterLineDiscountAmount1)
                {
                }
                column(FooterLineDisAmt2_ContratoTask; FooterLineDiscountAmount2)
                {
                }
                column(FooterLineAmt1_ContratoTask; FooterLineAmount1)
                {
                }
                column(FooterLineAmt2_ContratoTask; FooterLineAmount2)
                {
                }
                column(ContratoTaskNo_ContratoTaskCaption; FieldCaption("Contrato Task No."))
                {
                }
                column(TotalScheduleCaption; TotalScheduleCaptionLbl)
                {
                }
                column(TotalContractCaption; TotalContractCaptionLbl)
                {
                }
                dataitem("Contrato Planning Line"; "Contrato Planning Line")
                {
                    DataItemLink = "Contrato No." = field("Contrato No."), "Contrato Task No." = field("Contrato Task No."), "Planning Date" = field("Planning Date Filter");
                    DataItemLinkReference = "Contrato Task";
                    DataItemTableView = sorting("Contrato No.", "Contrato Task No.", "Line No.");
                    column(TotCostLCY_ContratoPlanningLine; "Total Cost (LCY)")
                    {
                    }
                    column(Qty_ContratoPlanningLine; Quantity)
                    {
                        IncludeCaption = false;
                    }
                    column(Desc_ContratoPlanningLine; Description)
                    {
                        IncludeCaption = false;
                    }
                    column(No_ContratoPlanningLine; "No.")
                    {
                        IncludeCaption = false;
                    }
                    column(Type_ContratoPlanningLine; Type)
                    {
                        IncludeCaption = false;
                    }
                    column(PlannDate_ContratoPlanningLine; Format("Planning Date"))
                    {
                    }
                    column(DocNo_ContratoPlanningLine; "Document No.")
                    {
                        IncludeCaption = false;
                    }
                    column(UOMCode_ContratoPlanningLine; "Unit of Measure Code")
                    {
                        IncludeCaption = false;
                    }
                    column(LineDiscAmLCY_ContratoPlanningLine; "Line Discount Amount (LCY)")
                    {
                    }
                    column(AmtLCY_ContratoPlanningLine; "Line Amount (LCY)")
                    {
                    }
                    column(LineType_ContratoPlanningLine; SelectStr(ConvertToContratoLineType().AsInteger(), Text000))
                    {
                    }
                    column(FieldLocalCurr_ContratoPlanningLine; CurrencyField = CurrencyField::"Local Currency")
                    {
                    }
                    column(TotalCost_ContratoPlanningLine; "Total Cost")
                    {
                    }
                    column(LineDiscAmt_ContratoPlanningLine; "Line Discount Amount")
                    {
                    }
                    column(LineAmt_ContratoPlanningLine; "Line Amount")
                    {
                    }
                    column(ForeignCurr_ContratoPlanningLine; CurrencyField = CurrencyField::"Foreign Currency")
                    {
                    }
                    column(TotalCost1_ContratoPlanningLine; TotalCost[1])
                    {
                    }
                    column(LineAmt1_ContratoPlanningLine; LineAmount[1])
                    {
                    }
                    column(LineDisAmt1_ContratoPlanningLine; LineDiscountAmount[1])
                    {
                    }
                    column(LineAmt2_ContratoPlanningLine; LineAmount[2])
                    {
                    }
                    column(LineDisAmt2_ContratoPlanningLine; LineDiscountAmount[2])
                    {
                    }
                    column(TotalCost2_ContratoPlanningLine; TotalCost[2])
                    {
                    }
                    column(ContratoNo_ContratoPlanningLine; "Contrato No.")
                    {
                    }
                    column(ContratoTaskNo_ContratoPlanningLine; "Contrato Task No.")
                    {
                    }
                    column(ScheduleCaption; ScheduleCaptionLbl)
                    {
                    }
                    column(ContractCaption; ContractCaptionLbl)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if CurrencyField = CurrencyField::"Local Currency" then begin
                            if "Schedule Line" then begin
                                FooterTotalCost1 += "Total Cost (LCY)";
                                TotalCost[1] += "Total Cost (LCY)";
                                FooterLineDiscountAmount1 += "Line Discount Amount (LCY)";
                                LineDiscountAmount[1] += "Line Discount Amount (LCY)";
                                FooterLineAmount1 += "Line Amount (LCY)";
                                LineAmount[1] += "Line Amount (LCY)";
                            end;
                            if "Contract Line" then begin
                                FooterTotalCost2 += "Total Cost (LCY)";
                                TotalCost[2] += "Total Cost (LCY)";
                                FooterLineDiscountAmount2 += "Line Discount Amount (LCY)";
                                LineDiscountAmount[2] += "Line Discount Amount (LCY)";
                                FooterLineAmount2 += "Line Amount (LCY)";
                                LineAmount[2] += "Line Amount (LCY)";
                            end;
                        end else begin
                            if "Schedule Line" then begin
                                FooterTotalCost1 += "Total Cost";
                                TotalCost[1] += "Total Cost";
                                FooterLineDiscountAmount1 += "Line Discount Amount";
                                LineDiscountAmount[1] += "Line Discount Amount";
                                FooterLineAmount1 += "Line Amount";
                                LineAmount[1] += "Line Amount";
                            end;
                            if "Contract Line" then begin
                                FooterTotalCost2 += "Total Cost";
                                TotalCost[2] += "Total Cost";
                                FooterLineDiscountAmount2 += "Line Discount Amount";
                                LineDiscountAmount[2] += "Line Discount Amount";
                                FooterLineAmount2 += "Line Amount";
                                LineAmount[2] += "Line Amount";
                            end;
                        end;
                    end;
                }

                trigger OnPreDataItem()
                begin
                    Clear(TotalCost);
                    Clear(LineDiscountAmount);
                    Clear(LineAmount);
                end;
            }

            trigger OnAfterGetRecord()
            var
                ContratoPlanningLine: Record "Contrato Planning Line";
            begin
                ContratoPlanningLine.SetRange("Contrato No.", "No.");
                ContratoPlanningLine.SetFilter("Planning Date", ContratoPlanningDateFilter);
                if not ContratoPlanningLine.FindFirst() then
                    CurrReport.Skip();

                FooterTotalCost1 := 0;
                FooterTotalCost2 := 0;
                FooterLineDiscountAmount1 := 0;
                FooterLineDiscountAmount2 := 0;
                FooterLineAmount1 := 0;
                FooterLineAmount2 := 0;
            end;

            trigger OnPreDataItem()
            begin
                SetFilter("No.", ContratoFilter);
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
                    field(CurrencyField; CurrencyField)
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
        ContratoPlannLineTypeCaption = 'Type';
        ContratoPlannLineDocNoCaption = 'Document No.';
        ContratoPlannLineNoCaption = 'No.';
        ContratoPlannLineDescCaption = 'Description';
        ContratoPlannLineQtyCaption = 'Quantity';
        ContratoPlannLineUOMCodeCptn = 'Unit of Measure Code';
        ContratoTaskNo_ContratoTaskCptn = 'Contrato Task No.';
    }

    trigger OnPreReport()
    begin
        JTFilter := "Contrato Task".GetFilters();
        ContratoFilter := "Contrato Task".GetFilter("Contrato No.");
        ContratoPlanningDateFilter := "Contrato Task".GetFilter("Planning Date Filter");
    end;

    var
        ContratoCalcBatches: Codeunit "Contrato Calculate Batches";
        TotalCost: array[2] of Decimal;
        LineDiscountAmount: array[2] of Decimal;
        LineAmount: array[2] of Decimal;
        ContratoFilter: Text;
        JTFilter: Text;
        CurrencyField: Option "Local Currency","Foreign Currency";
        Text000: Label 'Budget,Billable,Bud.+Bill.';
        FooterTotalCost1: Decimal;
        FooterTotalCost2: Decimal;
        FooterLineDiscountAmount1: Decimal;
        FooterLineDiscountAmount2: Decimal;
        FooterLineAmount1: Decimal;
        FooterLineAmount2: Decimal;
        ContratoPlanningLinesCaptionLbl: Label 'Contrato Planning Lines';
        CurrReportPageNoCaptionLbl: Label 'Page';
        ContratoPlannLinePlannDtCptnLbl: Label 'Planning Date';
        LineTypeCaptionLbl: Label 'Line Type';
        TotalScheduleCaptionLbl: Label 'Total Budget';
        TotalContractCaptionLbl: Label 'Total Billable';
        ScheduleCaptionLbl: Label 'Budget';
        ContractCaptionLbl: Label 'Billable';
        ContratoPlanningDateFilter: Text;

    procedure InitializeRequest(NewCurrencyField: Option "Local Currency","Foreign Currency")
    begin
        CurrencyField := NewCurrencyField;
    end;
}

