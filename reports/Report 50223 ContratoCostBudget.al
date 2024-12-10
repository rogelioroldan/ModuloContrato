report 50223 "Contrato Cost Budget"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Local/Contratos/Contrato/Reports/ContratoCostBudget.rdlc';
    ApplicationArea = All;
    Caption = 'Contrato Cost Budget';
    AdditionalSearchTerms = 'Contrato Cost Budget';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Contrato; Contrato)
        {
            RequestFilterFields = "No.", "Bill-to Customer No.", Status;
            column(Contrato_No_; "No.")
            {
            }
            column(Contrato_Planning_Date_Filter; "Planning Date Filter")
            {
            }
            dataitem(PageHeader; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                column(BudgetOptionText; BudgetOptionText)
                {
                }
                column(CompanyInformation_Name; CompanyInformation.Name)
                {
                }
                column(Title; Title)
                {
                }
                column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
                {
                }
                column(USERID; UserId)
                {
                }
                column(TIME; Time)
                {
                }
                column(Contrato_TABLECAPTION_____Filters______ContratoFilter; Contrato.TableCaption + ' Filters: ' + ContratoFilter)
                {
                }
                column(ContratoFilter; ContratoFilter)
                {
                }
                column(Contrato__Description_2_; Contrato."Description 2")
                {
                }
                column(Contrato_Description; Contrato.Description)
                {
                }
                column(Contrato_FIELDCAPTION__Ending_Date____________FORMAT_Contrato__Ending_Date__; Contrato.FieldCaption("Ending Date") + ': ' + Format(Contrato."Ending Date"))
                {
                }
                column(Contrato_FIELDCAPTION__Starting_Date____________FORMAT_Contrato__Starting_Date__; Contrato.FieldCaption("Starting Date") + ': ' + Format(Contrato."Starting Date"))
                {
                }
                column(PageHeader_Number; Number)
                {
                }
                column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
                {
                }
                column(Contrato_DescriptionCaption; Contrato_DescriptionCaptionLbl)
                {
                }
                column(Contrato_Planning_Line__Contrato_Task_No__Caption; "Contrato Planning Line".FieldCaption("Contrato Task No."))
                {
                }
                column(PADSTR____2____Contrato_Task__Indentation_____Contrato_Task__DescriptionCaption; PADSTR____2____Contrato_Task__Indentation_____Contrato_Task__DescriptionCaptionLbl)
                {
                }
                column(Contrato_Planning_Line_TypeCaption; "Contrato Planning Line".FieldCaption(Type))
                {
                }
                column(Contrato_Planning_Line__No__Caption; "Contrato Planning Line".FieldCaption("No."))
                {
                }
                column(Contrato_Planning_Line_QuantityCaption; "Contrato Planning Line".FieldCaption(Quantity))
                {
                }
                column(Contrato_Planning_Line__Unit_Cost__LCY__Caption; "Contrato Planning Line".FieldCaption("Unit Cost (LCY)"))
                {
                }
                column(Contrato_Planning_Line__Total_Cost__LCY__Caption; "Contrato Planning Line".FieldCaption("Total Cost (LCY)"))
                {
                }
                column(Contrato_Planning_Line__Unit_Price__LCY__Caption; "Contrato Planning Line".FieldCaption("Unit Price (LCY)"))
                {
                }
                column(Contrato_Planning_Line__Total_Price__LCY__Caption; "Contrato Planning Line".FieldCaption("Total Price (LCY)"))
                {
                }
                dataitem("Contrato Task"; "Contrato Task")
                {
                    DataItemLink = "Contrato No." = field("No.");
                    DataItemLinkReference = Contrato;
                    DataItemTableView = sorting("Contrato No.", "Contrato Task No.");
                    column(Contrato_Task_Contrato_No_; "Contrato No.")
                    {
                    }
                    column(Contrato_Task_Contrato_Task_No_; "Contrato Task No.")
                    {
                    }
                    dataitem(BlankLine; "Integer")
                    {
                        DataItemTableView = sorting(Number);
                        column(Contrato_Task___No__of_Blank_Lines_; "Contrato Task"."No. of Blank Lines")
                        {
                        }
                        column(BlankLine_Number; Number)
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            SetRange(Number, 1, "Contrato Task"."No. of Blank Lines");
                        end;
                    }
                    dataitem("Contrato Planning Line"; "Contrato Planning Line")
                    {
                        DataItemLink = "Contrato No." = field("No."), "Planning Date" = field("Planning Date Filter");
                        DataItemLinkReference = Contrato;
                        DataItemTableView = sorting("Contrato No.", "Contrato Task No.", "Schedule Line", "Planning Date") where(Type = filter(<> Text));
                        column(Contrato_Planning_Line__Contrato_Task_No__; "Contrato Task No.")
                        {
                        }
                        column(PADSTR____2____Contrato_Task__Indentation_____Contrato_Task__Description; PadStr('', 2 * "Contrato Task".Indentation) + "Contrato Task".Description)
                        {
                        }
                        column(Contrato_Planning_Line_Type; Type)
                        {
                        }
                        column(Contrato_Planning_Line__No__; "No.")
                        {
                        }
                        column(Contrato_Planning_Line_Quantity; Quantity)
                        {
                        }
                        column(Contrato_Planning_Line__Unit_Cost__LCY__; "Unit Cost (LCY)")
                        {
                        }
                        column(Contrato_Planning_Line__Total_Cost__LCY__; "Total Cost (LCY)")
                        {
                        }
                        column(Contrato_Planning_Line__Unit_Price__LCY__; "Unit Price (LCY)")
                        {
                        }
                        column(Contrato_Planning_Line__Total_Price__LCY__; "Total Price (LCY)")
                        {
                        }
                        column(Contrato_Task___Contrato_Task_Type_; "Contrato Task"."Contrato Task Type")
                        {
                        }
                        column(Contrato_Planning_Line_Contrato_No_; "Contrato No.")
                        {
                        }
                        column(Contrato_Planning_Line_Line_No_; "Line No.")
                        {
                        }
                        column(Contrato_Planning_Line_Planning_Date; "Planning Date")
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            case "Contrato Task"."Contrato Task Type" of
                                "Contrato Task"."Contrato Task Type"::Posting:
                                    SetRange("Contrato Task No.", "Contrato Task"."Contrato Task No.");
                                "Contrato Task"."Contrato Task Type"::Heading, "Contrato Task"."Contrato Task Type"::"Begin-Total":
                                    CurrReport.Break();
                                "Contrato Task"."Contrato Task Type"::Total, "Contrato Task"."Contrato Task Type"::"End-Total":
                                    SetFilter("Contrato Task No.", "Contrato Task".Totaling);
                            end;
                            case BudgetAmountsPer of
                                BudgetAmountsPer::Schedule:
                                    SetFilter("Line Type", '%1|%2', "Line Type"::Budget, "Line Type"::"Both Budget and Billable");
                                BudgetAmountsPer::Contract:
                                    SetFilter("Line Type", '%1|%2', "Line Type"::Billable, "Line Type"::"Both Budget and Billable");
                            end;
                        end;
                    }
                    dataitem("Integer"; "Integer")
                    {
                        DataItemTableView = sorting(Number) where(Number = const(1));
                        column(PADSTR____2____Contrato_Task__Indentation_____Contrato_Task__Description_Control1480007; PadStr('', 2 * "Contrato Task".Indentation) + "Contrato Task".Description)
                        {
                        }
                        column(Contrato_Task___Contrato_Task_No__; "Contrato Task"."Contrato Task No.")
                        {
                        }
                        column(Contrato_Task___Contrato_Task_Type__Control1020002; "Contrato Task"."Contrato Task Type")
                        {
                        }
                        column(Contrato_Task___New_Page_; "Contrato Task"."New Page")
                        {
                        }
                        column(PADSTR____2____Contrato_Task__Indentation_____Contrato_Task__Description_Control1480009; PadStr('', 2 * "Contrato Task".Indentation) + "Contrato Task".Description)
                        {
                        }
                        column(Contrato_Task___Contrato_Task_No___Control1480010; "Contrato Task"."Contrato Task No.")
                        {
                        }
                        column(Contrato_Planning_Line___Total_Cost__LCY__; "Contrato Planning Line"."Total Cost (LCY)")
                        {
                        }
                        column(Contrato_Planning_Line___Total_Price__LCY__; "Contrato Planning Line"."Total Price (LCY)")
                        {
                        }
                        column(Integer_Number; Number)
                        {
                        }
                    }
                }
            }

            trigger OnAfterGetRecord()
            begin
                Title := StrSubstNo(Text000, "No.");
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
                        ApplicationArea = All;
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
            BudgetOptionText := Text003
        else
            BudgetOptionText := Text004;
    end;

    var
        CompanyInformation: Record "Company Information";
        ContratoFilter: Text;
        Title: Text[100];
        Text000: Label 'Contrato Cost Budget for Contrato: %1';
        BudgetAmountsPer: Option Schedule,Contract;
        BudgetOptionText: Text[50];
        Text003: Label 'Budgeted Amounts are per the Budget';
        Text004: Label 'Budgeted Amounts are per the Contract';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Contrato_DescriptionCaptionLbl: Label 'Contrato Description';
        PADSTR____2____Contrato_Task__Indentation_____Contrato_Task__DescriptionCaptionLbl: Label 'Contrato Task Description';

    procedure GetItemDescription(Type: Option Resource,Item,"G/L Account"; No: Code[20]): Text[50]
    var
        Res: Record Resource;
        Item: Record Item;
        GLAcc: Record "G/L Account";
        Result: Text;
    begin
        case Type of
            Type::Resource:
                if Res.Get(No) then
                    Result := Res.Name;
            Type::Item:
                if Item.Get(No) then
                    Result := Item.Description;
            Type::"G/L Account":
                if GLAcc.Get(No) then
                    Result := GLAcc.Name;
        end;
        exit(CopyStr(Result, 1, 50))
    end;
}

