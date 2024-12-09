report 50227 "Change Contrato Dates"
{
    AdditionalSearchTerms = 'Change Contrato Planning Line Dates';
    ApplicationArea = Contratos;
    Caption = 'Change Contrato Planning Line Dates';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("Contrato Task"; "Contrato Task")
        {
            DataItemTableView = sorting("Contrato No.", "Contrato Task No.");
            RequestFilterFields = "Contrato No.", "Contrato Task No.";

            trigger OnAfterGetRecord()
            begin
                Clear(CalculateBatches);
                if ChangePlanningDate then
                    if Linetype2 <> Linetype2::" " then
                        CalculateBatches.ChangePlanningDates(
                          "Contrato Task", ScheduleLine2, ContractLine2, PeriodLength2, FixedDate2, StartingDate2, EndingDate2);
                Clear(CalculateBatches);
                if ChangeCurrencyDate then
                    if Linetype <> Linetype::" " then
                        CalculateBatches.ChangeCurrencyDates(
                          "Contrato Task", ScheduleLine, ContractLine,
                          PeriodLength, FixedDate, StartingDate, EndingDate);
            end;

            trigger OnPostDataItem()
            begin
                CalculateBatches.ChangeDatesEnd();
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
                    group("Currency Date")
                    {
                        Caption = 'Currency Date';
                        field(ChangeCurrencyDate; ChangeCurrencyDate)
                        {
                            ApplicationArea = Contratos;
                            Caption = 'Change Currency Date';
                            ToolTip = 'Specifies that currencies will be updated on the Contratos that are included in the batch Contrato.';
                        }
                        field(ChangeDateExpressionCurrency; PeriodLength)
                        {
                            ApplicationArea = Contratos;
                            Caption = 'Change Date Expression';
                            ToolTip = 'Specifies how the dates on the entries that are copied will be changed by using a date formula.';

                            trigger OnValidate()
                            begin
                                FixedDate := 0D;
                            end;
                        }
                        field(FixedDateCurrency; FixedDate)
                        {
                            ApplicationArea = Contratos;
                            Caption = 'Fixed Date';
                            ToolTip = 'Specifies a date that the currency date on all planning lines will be moved to.';

                            trigger OnValidate()
                            begin
                                Clear(PeriodLength);
                            end;
                        }
                        field(IncludeLineTypeCurrency; Linetype)
                        {
                            ApplicationArea = Contratos;
                            Caption = 'Include Line type';
                            OptionCaption = ' ,Budget,Billable,Budget+Billable';
                            ToolTip = 'Specifies the Contrato planning line type you want to change the currency date for.';
                        }
                        field(IncludeCurrDateFrom; StartingDate)
                        {
                            ApplicationArea = Contratos;
                            Caption = 'Include Curr. Date From';
                            ToolTip = 'Specifies the starting date of the period for which you want currency dates to be moved. Only planning lines with a currency date on or after this date are included.';
                        }
                        field(IncludeCurrDateTo; EndingDate)
                        {
                            ApplicationArea = Contratos;
                            Caption = 'Include Curr. Date To';
                            ToolTip = 'Specifies the ending date of the period for which you want currency dates to be moved. Only planning lines with a currency date on or before this date are included.';
                        }
                    }
                    group("Planning Date")
                    {
                        Caption = 'Planning Date';
                        field(ChangePlanningDate; ChangePlanningDate)
                        {
                            ApplicationArea = Contratos;
                            Caption = 'Change Planning Date';
                            ToolTip = 'Specifies that planning dates will be changed on the Contratos that are included in the batch Contrato.';
                        }
                        field(ChangeDateExpressionPlanning; PeriodLength2)
                        {
                            ApplicationArea = Contratos;
                            Caption = 'Change Date Expression';
                            ToolTip = 'Specifies how the dates on the entries that are copied will be changed by using a date formula.';

                            trigger OnValidate()
                            begin
                                FixedDate2 := 0D;
                            end;
                        }
                        field(FixedDatePlanning; FixedDate2)
                        {
                            ApplicationArea = Contratos;
                            Caption = 'Fixed Date';
                            ToolTip = 'Specifies a date that the planning date on all planning lines will be moved to.';

                            trigger OnValidate()
                            begin
                                Clear(PeriodLength2);
                            end;
                        }
                        field(IncludeLineTypePlanning; Linetype2)
                        {
                            ApplicationArea = Contratos;
                            Caption = 'Include Line type';
                            OptionCaption = ' ,Budget,Billable,Budget+Billable';
                            ToolTip = 'Specifies the Contrato planning line type you want to change the planning date for.';
                        }
                        field(IncludePlanDateFrom; StartingDate2)
                        {
                            ApplicationArea = Contratos;
                            Caption = 'Include Plan. Date From';
                            ToolTip = 'Specifies the starting date of the period for which you want a Planning Date to be moved. Only planning lines with a Planning Date on or after this date are included.';
                        }
                        field(IncludePlanDateTo; EndingDate2)
                        {
                            ApplicationArea = Contratos;
                            Caption = 'Include Plan. Date To';
                            ToolTip = 'Specifies the ending date of the period for which you want a Planning Date to be moved. Only planning lines with a Planning Date on or before this date are included.';
                        }
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
        ScheduleLine := false;
        ContractLine := false;
        if Linetype = Linetype::Budget then
            ScheduleLine := true;
        if Linetype = Linetype::Billable then
            ContractLine := true;
        if Linetype = Linetype::"Budget+Billable" then begin
            ScheduleLine := true;
            ContractLine := true;
        end;

        ScheduleLine2 := false;
        ContractLine2 := false;
        if Linetype2 = Linetype2::Budget then
            ScheduleLine2 := true;
        if Linetype2 = Linetype2::Billable then
            ContractLine2 := true;
        if Linetype2 = Linetype2::"Budget+Billable" then begin
            ScheduleLine2 := true;
            ContractLine2 := true;
        end;
        if (Linetype = Linetype::" ") and (Linetype2 = Linetype2::" ") then
            Error(Text000);
        if not ChangePlanningDate and not ChangeCurrencyDate then
            Error(Text000);
        if ChangeCurrencyDate and (Linetype = Linetype::" ") then
            Error(Text001);
        if ChangePlanningDate and (Linetype2 = Linetype2::" ") then
            Error(Text002);
    end;

    var
        CalculateBatches: Codeunit "Contrato Calculate Batches";
        PeriodLength: DateFormula;
        PeriodLength2: DateFormula;
        ScheduleLine: Boolean;
        ContractLine: Boolean;
        ScheduleLine2: Boolean;
        ContractLine2: Boolean;
        Linetype: Option " ",Budget,Billable,"Budget+Billable";
        Linetype2: Option " ",Budget,Billable,"Budget+Billable";
        FixedDate: Date;
        FixedDate2: Date;
        StartingDate: Date;
        EndingDate: Date;
        StartingDate2: Date;
        EndingDate2: Date;
        Text000: Label 'There is nothing to change.';
        ChangePlanningDate: Boolean;
        ChangeCurrencyDate: Boolean;
        Text001: Label 'You must specify a Line Type for changing the currency date.';
        Text002: Label 'You must specify a Line Type for changing the planning date.';
}

