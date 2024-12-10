report 50217 "Items per Contrato"
{
    AdditionalSearchTerms = 'Items per Contrato';
    DefaultLayout = RDLC;
    RDLCLayout = './Contratos/Contrato/Reports/ItemsperContrato.rdlc';
    ApplicationArea = All;
    Caption = 'Items per Contrato';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Contrato; Contrato)
        {
            DataItemTableView = sorting("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Posting Date Filter";
            column(TodayFormatted; Format(Today))
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
            column(ItemTableCaptItemFilter; Item.TableCaption + ': ' + ItemFilter)
            {
            }
            column(ItemFilter; ItemFilter)
            {
            }
            column(No_Contrato; "No.")
            {
            }
            column(Description_Contrato; Description)
            {
            }
            column(Amount3_ContratoBuffer; TempContratoBuffer."Amount 3")
            {
            }
            column(Amount1_ContratoBuffer; TempContratoBuffer."Amount 2")
            {
            }
            column(ItemsperContratoCaption; ItemsperContratoCaptionLbl)
            {
            }
            column(CurrReportPageNoCaption; CurrReportPageNoCaptionLbl)
            {
            }
            column(AllamountsareinLCYCaption; AllamountsareinLCYCaptionLbl)
            {
            }
            column(ContratoBufferLineAmountCaption; ContratoBufferLineAmountCaptionLbl)
            {
            }
            column(ContratoBufferTotalCostCaption; ContratoBufferTotalCostCaptionLbl)
            {
            }
            column(ContratoBuffeUOMCaption; ContratoBuffeUOMCaptionLbl)
            {
            }
            column(ContratoBufferQuantityCaption; ContratoBufferQuantityCaptionLbl)
            {
            }
            column(ContratoBufferDescriptionCaption; ContratoBufferDescriptionCaptionLbl)
            {
            }
            column(ItemNoCaption; ItemNoCaptionLbl)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                column(ActNo1_ContratoBuffer; TempContratoBuffer."Account No. 1")
                {
                }
                column(Description_ContratoBuffer; TempContratoBuffer.Description)
                {
                }
                column(ActNo2_ContratoBuffer; TempContratoBuffer."Account No. 2")
                {
                }
                column(Amount2_ContratoBuffer; TempContratoBuffer."Amount 1")
                {
                    DecimalPlaces = 0 : 5;
                }
                column(TableCaptionContratoNo; TotalForTxt + ' ' + Contrato.TableCaption + ' ' + Contrato."No.")
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
                TempContratoBuffer2.ReportContratoItem(Contrato, Item, TempContratoBuffer);
            end;
        }
        dataitem(Item2; Item)
        {
            RequestFilterFields = "No.";

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
        Item.CopyFilters(Item2);
        ContratoFilter := Contrato.GetFilters();
        ItemFilter := Item.GetFilters();
    end;

    var
        Item: Record Item;
        ContratoFilter: Text;
        ItemFilter: Text;
        ItemsperContratoCaptionLbl: Label 'Items per Contrato';
        CurrReportPageNoCaptionLbl: Label 'Page';
        AllamountsareinLCYCaptionLbl: Label 'All amounts are in LCY';
        ContratoBufferLineAmountCaptionLbl: Label 'Line Amount';
        ContratoBufferTotalCostCaptionLbl: Label 'Total Cost';
        ContratoBuffeUOMCaptionLbl: Label 'Unit of Measure';
        ContratoBufferQuantityCaptionLbl: Label 'Quantity';
        ContratoBufferDescriptionCaptionLbl: Label 'Description';
        ItemNoCaptionLbl: Label 'Item No.';
        TotalCaptionLbl: Label 'Total';

        TotalForTxt: Label 'Total for';

    protected var
        TempContratoBuffer2: Record "Contrato Buffer" temporary;
        TempContratoBuffer: Record "Contrato Buffer" temporary;
}

