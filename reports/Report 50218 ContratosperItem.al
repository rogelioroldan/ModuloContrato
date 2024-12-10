report 50218 "Contratos per Item"
{
    AdditionalSearchTerms = 'Contratos per Item';
    DefaultLayout = RDLC;
    RDLCLayout = './Contratos/Contrato/Reports/ContratosperItem.rdlc';
    ApplicationArea = All;
    Caption = 'Contratos per Item';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";
            column(TodayFormatted; Format(Today))
            {
            }
            column(CompanyName; COMPANYPROPERTY.DisplayName())
            {
            }
            column(ItemTableCaptiontemFilter; TableCaption + ': ' + ItemFilter)
            {
            }
            column(ItemFilter; ItemFilter)
            {
            }
            column(ContratoTableCaptionContratoFilter; Contrato.TableCaption + ': ' + ContratoFilter)
            {
            }
            column(ContratoFilter; ContratoFilter)
            {
            }
            column(Description_Item; Description)
            {
            }
            column(No_Item; "No.")
            {
            }
            column(Amount3_ContratoBuffer; TempContratoBuffer."Amount 3")
            {
            }
            column(Amount2_ContratoBuffer; TempContratoBuffer."Amount 2")
            {
            }
            column(CurrReportPageNoCaption; CurrReportPageNoCaptionLbl)
            {
            }
            column(ContratosperItemCaption; ContratosperItemCaptionLbl)
            {
            }
            column(AllamountsareinLCYCaption; AllamountsareinLCYCaptionLbl)
            {
            }
            column(ContratoNoCaption; ContratoNoCaptionLbl)
            {
            }
            column(ContratoBufferDscrptnCaption; ContratoBufferDscrptnCaptionLbl)
            {
            }
            column(ContratoBufferQuantityCaption; ContratoBufferQuantityCaptionLbl)
            {
            }
            column(ContratoBufferUOMCaption; ContratoBufferUOMCaptionLbl)
            {
            }
            column(ContratoBufferTotalCostCaption; ContratoBufferTotalCostCaptionLbl)
            {
            }
            column(ContratoBufferLineAmountCaption; ContratoBufferLineAmountCaptionLbl)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                column(AccountNo1_ContratoBuffer; TempContratoBuffer."Account No. 1")
                {
                }
                column(Description_ContratoBuffer; TempContratoBuffer.Description)
                {
                }
                column(AccountNo2_ContratoBuffer; TempContratoBuffer."Account No. 2")
                {
                }
                column(Amount1_ContratoBuffer; TempContratoBuffer."Amount 1")
                {
                    DecimalPlaces = 0 : 5;
                }
                column(TableCapionItemNo; Text000 + ' ' + Item.TableCaption + ' ' + Item."No.")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then begin
                        if not TempContratoBuffer.Find('-') then
                            CurrReport.Break();
                    end else
                        if TempContratoBuffer.Next() = 0 then
                            CurrReport.Break();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                TempContratoBuffer2.ReportItemContrato(Item, Contrato, TempContratoBuffer);
            end;
        }
        dataitem(Contrato2; Contrato)
        {
            RequestFilterFields = "No.", "Bill-to Customer No.", "Posting Date Filter";

            trigger OnPreDataItem()
            begin
                CurrReport.Break();
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
        ItemFilter := Item.GetFilters();

        Contrato.CopyFilters(Contrato2);
        ContratoFilter := Contrato.GetFilters();
    end;

    var
        Contrato: Record Contrato;
        TempContratoBuffer2: Record "Contrato Buffer" temporary;
        TempContratoBuffer: Record "Contrato Buffer" temporary;
        ContratoFilter: Text;
        ItemFilter: Text;
        Text000: Label 'Total for';
        CurrReportPageNoCaptionLbl: Label 'Page';
        ContratosperItemCaptionLbl: Label 'Contratos per Item';
        AllamountsareinLCYCaptionLbl: Label 'All amounts are in LCY';
        ContratoNoCaptionLbl: Label 'Contrato No.';
        ContratoBufferDscrptnCaptionLbl: Label 'Description';
        ContratoBufferQuantityCaptionLbl: Label 'Quantity';
        ContratoBufferUOMCaptionLbl: Label 'Unit of Measure';
        ContratoBufferTotalCostCaptionLbl: Label 'Total Cost';
        ContratoBufferLineAmountCaptionLbl: Label 'Line Amount';
        TotalCaptionLbl: Label 'Total';
}

