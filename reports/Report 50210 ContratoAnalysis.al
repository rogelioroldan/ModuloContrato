report 50210 "Contrato Analysis"
{
    AdditionalSearchTerms = 'Contrato overview, Contrato Analysis';
    DefaultLayout = RDLC;
    RDLCLayout = './Contratos/Contrato/Reports/ContratoAnalysis.rdlc';
    ApplicationArea = All;
    Caption = 'Contrato Analysis';
    UsageCategory = ReportsAndAnalysis;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Contrato; Contrato)
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Posting Date Filter", "Planning Date Filter";
            column(TodayFormatted; Format(Today, 0, 4))
            {
            }
            column(CompanyName; COMPANYPROPERTY.DisplayName())
            {
            }
            column(ContratotableCaptContratoFilter; TableCaption + ': ' + ContratoFilter)
            {
            }
            column(ContratoFilter; ContratoFilter)
            {
            }
            column(ContratoTasktableCaptFilter; "Contrato Task".TableCaption + ': ' + ContratoTaskFilter)
            {
            }
            column(ContratoTaskFilter; ContratoTaskFilter)
            {
            }
            column(No_Contrato; "No.")
            {
            }
            column(CurrReportPageNoCaption; CurrReportPageNoCaptionLbl)
            {
            }
            column(ContratoAnalysisCapt; ContratoAnalysisCaptLbl)
            {
            }
            dataitem("Contrato Task"; "Contrato Task")
            {
                DataItemLink = "Contrato No." = field("No.");
                DataItemTableView = sorting("Contrato No.", "Contrato Task No.");
                RequestFilterFields = "Contrato Task No.";
                column(HeadLineText8; HeadLineText[8])
                {
                }
                column(HeadLineText7; HeadLineText[7])
                {
                }
                column(HeadLineText6; HeadLineText[6])
                {
                }
                column(HeadLineText5; HeadLineText[5])
                {
                }
                column(HeadLineText4; HeadLineText[4])
                {
                }
                column(HeadLineText3; HeadLineText[3])
                {
                }
                column(HeadLineText2; HeadLineText[2])
                {
                }
                column(HeadLineText1; HeadLineText[1])
                {
                }
                column(Description_Contrato; Contrato.Description)
                {
                }
                column(DescriptionCaption; DescriptionCaptionLbl)
                {
                }
                column(ContratoTaskNoCapt; ContratoTaskNoCaptLbl)
                {
                }
                dataitem(BlankLine; "Integer")
                {
                    DataItemTableView = sorting(Number);

                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1, "Contrato Task"."No. of Blank Lines");
                    end;
                }
                dataitem("Integer"; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(ContratoTaskNo_ContratoTask; "Contrato Task"."Contrato Task No.")
                    {
                    }
                    column(Indentation_ContratoTask; PadStr('', 2 * "Contrato Task".Indentation) + "Contrato Task".Description)
                    {
                    }
                    column(ShowIntBody1; "Contrato Task"."Contrato Task Type" in ["Contrato Task"."Contrato Task Type"::Heading, "Contrato Task"."Contrato Task Type"::"Begin-Total"])
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
                    column(Amt7; Amt[7])
                    {
                    }
                    column(Amt8; Amt[8])
                    {
                    }
                    column(ShowIntBody2; "Contrato Task"."Contrato Task Type" in ["Contrato Task"."Contrato Task Type"::Total, "Contrato Task"."Contrato Task Type"::"End-Total"])
                    {
                    }
                    column(ShowIntBody3; ("Contrato Task"."Contrato Task Type" in ["Contrato Task"."Contrato Task Type"::Posting]) and PrintSection)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        PrintSection := true;
                        if ExcludeContratoTask then begin
                            PrintSection := false;
                            for I := 1 to 8 do
                                if (Amt[I] <> 0) and (AmountField[I] <> AmountField[I] ::" ") then
                                    PrintSection := true;
                        end;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(ContratoCalcStatistics);
                    ContratoCalcStatistics.ReportAnalysis(Contrato, "Contrato Task", Amt, AmountField, CurrencyField, false);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                ContratoCalcStatistics.GetHeadLineText(AmountField, CurrencyField, HeadLineText, Contrato);
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
                    field("AmountField[1]"; AmountField[1])
                    {
                        ApplicationArea = All;
                        Caption = 'Amount Field 1 ';
                        OptionCaption = ' ,Budget Price,Usage Price,Billable Price,Invoiced Price,Budget Cost,Usage Cost,Billable Cost,Invoiced Cost,Budget Profit,Usage Profit,Billable Profit,Invoiced Profit';
                        ToolTip = 'Specifies that you want to use a combination of the available Amount fields to create your own analysis. For each field, select one of the following prices, costs, or profit values: Budget, Usage, Billable, and Invoiced.';
                    }
                    field("CurrencyField[1]"; CurrencyField[1])
                    {
                        ApplicationArea = All;
                        Caption = 'Currency Field 1';
                        OptionCaption = 'Local Currency,Foreign Currency';
                        ToolTip = 'Specifies if the currency is specified in the local currency or in a foreign currency.';
                    }
                    field("AmountField[2]"; AmountField[2])
                    {
                        ApplicationArea = All;
                        Caption = 'Amount Field 2';
                        OptionCaption = ' ,Budget Price,Usage Price,Billable Price,Invoiced Price,Budget Cost,Usage Cost,Billable Cost,Invoiced Cost,Budget Profit,Usage Profit,Billable Profit,Invoiced Profit';
                        ToolTip = 'Specifies an Amount field that you use to create your own analysis. For each field, select one of the following prices, costs, or profit values: Budget, Usage, Billable, and Invoiced.';
                    }
                    field("CurrencyField[2]"; CurrencyField[2])
                    {
                        ApplicationArea = All;
                        Caption = 'Currency Field 2';
                        OptionCaption = 'Local Currency,Foreign Currency';
                        ToolTip = 'Specifies if the currency is specified in the local currency or in a foreign currency.';
                    }
                    field("AmountField[3]"; AmountField[3])
                    {
                        ApplicationArea = All;
                        Caption = 'Amount Field 3';
                        OptionCaption = ' ,Budget Price,Usage Price,Billable Price,Invoiced Price,Budget Cost,Usage Cost,Billable Cost,Invoiced Cost,Budget Profit,Usage Profit,Billable Profit,Invoiced Profit';
                        ToolTip = 'Specifies an Amount field that you use to create your own analysis. For each field, select one of the following prices, costs, or profit values: Budget, Usage, Billable, and Invoiced.';
                    }
                    field("CurrencyField[3]"; CurrencyField[3])
                    {
                        ApplicationArea = All;
                        Caption = 'Currency Field 3';
                        OptionCaption = 'Local Currency,Foreign Currency';
                        ToolTip = 'Specifies if the currency is specified in the local currency or in a foreign currency.';
                    }
                    field("AmountField[4]"; AmountField[4])
                    {
                        ApplicationArea = All;
                        Caption = 'Amount Field 4';
                        OptionCaption = ' ,Budget Price,Usage Price,Billable Price,Invoiced Price,Budget Cost,Usage Cost,Billable Cost,Invoiced Cost,Budget Profit,Usage Profit,Billable Profit,Invoiced Profit';
                        ToolTip = 'Specifies an Amount field that you use to create your own analysis. For each field, select one of the following prices, costs, or profit values: Budget, Usage, Billable, and Invoiced.';
                    }
                    field("CurrencyField[4]"; CurrencyField[4])
                    {
                        ApplicationArea = All;
                        Caption = 'Currency Field 4';
                        OptionCaption = 'Local Currency,Foreign Currency';
                        ToolTip = 'Specifies if the currency is specified in the local currency or in a foreign currency.';
                    }
                    field("AmountField[5]"; AmountField[5])
                    {
                        ApplicationArea = All;
                        Caption = 'Amount Field 5';
                        OptionCaption = ' ,Budget Price,Usage Price,Billable Price,Invoiced Price,Budget Cost,Usage Cost,Billable Cost,Invoiced Cost,Budget Profit,Usage Profit,Billable Profit,Invoiced Profit';
                        ToolTip = 'Specifies an Amount field that you use to create your own analysis. For each field, select one of the following prices, costs, or profit values: Budget, Usage, Billable, and Invoiced.';
                    }
                    field("CurrencyField[5]"; CurrencyField[5])
                    {
                        ApplicationArea = All;
                        Caption = 'Currency Field 5';
                        OptionCaption = 'Local Currency,Foreign Currency';
                        ToolTip = 'Specifies if the currency is specified in the local currency or in a foreign currency.';
                    }
                    field("AmountField[6]"; AmountField[6])
                    {
                        ApplicationArea = All;
                        Caption = 'Amount Field 6';
                        OptionCaption = ' ,Budget Price,Usage Price,Billable Price,Invoiced Price,Budget Cost,Usage Cost,Billable Cost,Invoiced Cost,Budget Profit,Usage Profit,Billable Profit,Invoiced Profit';
                        ToolTip = 'Specifies an Amount field that you use to create your own analysis. For each field, select one of the following prices, costs, or profit values: Budget, Usage, Billable, and Invoiced.';
                    }
                    field("CurrencyField[6]"; CurrencyField[6])
                    {
                        ApplicationArea = All;
                        Caption = 'Currency Field 6';
                        OptionCaption = 'Local Currency,Foreign Currency';
                        ToolTip = 'Specifies if the currency is specified in the local currency or in a foreign currency.';
                    }
                    field("AmountField[7]"; AmountField[7])
                    {
                        ApplicationArea = All;
                        Caption = 'Amount Field 7';
                        OptionCaption = ' ,Budget Price,Usage Price,Billable Price,Invoiced Price,Budget Cost,Usage Cost,Billable Cost,Invoiced Cost,Budget Profit,Usage Profit,Billable Profit,Invoiced Profit';
                        ToolTip = 'Specifies an Amount field that you use to create your own analysis. For each field, select one of the following prices, costs, or profit values: Budget, Usage, Billable, and Invoiced.';
                    }
                    field("CurrencyField[7]"; CurrencyField[7])
                    {
                        ApplicationArea = All;
                        Caption = 'Currency Field 7';
                        OptionCaption = 'Local Currency,Foreign Currency';
                        ToolTip = 'Specifies if the currency is specified in the local currency or in a foreign currency.';
                    }
                    field("AmountField[8]"; AmountField[8])
                    {
                        ApplicationArea = All;
                        Caption = 'Amount Field 8';
                        OptionCaption = ' ,Budget Price,Usage Price,Billable Price,Invoiced Price,Budget Cost,Usage Cost,Billable Cost,Invoiced Cost,Budget Profit,Usage Profit,Billable Profit,Invoiced Profit';
                        ToolTip = 'Specifies an Amount field that you use to create your own analysis. For each field, select one of the following prices, costs, or profit values: Budget, Usage, Billable, and Invoiced.';
                    }
                    field("CurrencyField[8]"; CurrencyField[8])
                    {
                        ApplicationArea = All;
                        Caption = 'Currency Field 8';
                        OptionCaption = 'Local Currency,Foreign Currency';
                        ToolTip = 'Specifies if the currency is specified in the local currency or in a foreign currency.';
                    }
                    field(ExcludeContratoTask; ExcludeContratoTask)
                    {
                        ApplicationArea = All;
                        Caption = 'Exclude Zero-Lines';
                        MultiLine = true;
                        ToolTip = 'Specifies that lines with zero content are excluded from the view.';
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
    end;

    var
        ContratoCalcStatistics: Codeunit "Contrato Calculate Statistics";
        HeadLineText: array[8] of Text[50];
        Amt: array[8] of Decimal;
        AmountField: array[8] of Option " ","Budget Price","Usage Price","Billable Price","Invoiced Price","Budget Cost","Usage Cost","Billable Cost","Invoiced Cost","Budget Profit","Usage Profit","Billable Profit","Invoiced Profit";
        CurrencyField: array[8] of Option "Local Currency","Foreign Currency";
        ContratoFilter: Text;
        ContratoTaskFilter: Text;
        ExcludeContratoTask: Boolean;
        PrintSection: Boolean;
        I: Integer;
        CurrReportPageNoCaptionLbl: Label 'Page';
        ContratoAnalysisCaptLbl: Label 'Contrato Analysis';
        DescriptionCaptionLbl: Label 'Description';
        ContratoTaskNoCaptLbl: Label 'Contrato Task No.';

    procedure InitializeRequest(NewAmountField: array[8] of Option " ","Budget Price","Usage Price","Billable Price","Invoiced Price","Budget Cost","Usage Cost","Billable Cost","Invoiced Cost","Budget Profit","Usage Profit","Billable Profit","Invoiced Profit"; NewCurrencyField: array[8] of Option "Local Currency","Foreign Currency"; NewExcludeContratoTask: Boolean)
    begin
        AmountField[1] := NewAmountField[1];
        CurrencyField[1] := NewCurrencyField[1];
        AmountField[2] := NewAmountField[2];
        CurrencyField[2] := NewCurrencyField[2];
        AmountField[3] := NewAmountField[3];
        CurrencyField[3] := NewCurrencyField[3];
        AmountField[4] := NewAmountField[4];
        CurrencyField[4] := NewCurrencyField[4];
        AmountField[5] := NewAmountField[5];
        CurrencyField[5] := NewCurrencyField[5];
        AmountField[6] := NewAmountField[6];
        CurrencyField[6] := NewCurrencyField[6];
        AmountField[7] := NewAmountField[7];
        CurrencyField[7] := NewCurrencyField[7];
        AmountField[8] := NewAmountField[8];
        CurrencyField[8] := NewCurrencyField[8];
        ExcludeContratoTask := NewExcludeContratoTask;
    end;
}

