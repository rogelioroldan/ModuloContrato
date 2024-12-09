report 50208 "ContratoActualtoBudget(Cost)"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Local/Projects/Project/Reports/ContratoActualtoBudgetCost.rdlc';
    ApplicationArea = Contratos;
    Caption = 'Project Actual to Budget (Cost)';
    AdditionalSearchTerms = 'Contrato Actual to Budget (Cost)';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Contrato; Contrato)
        {
            RequestFilterFields = "No.", "Bill-to Customer No.", "Posting Date Filter", "Planning Date Filter", Status;
            column(Contrato_No_; "No.")
            {
            }
            column(Contrato_Planning_Date_Filter; "Planning Date Filter")
            {
            }
            column(Contrato_Posting_Date_Filter; "Posting Date Filter")
            {
            }
            dataitem(PageHeader; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                column(USERID; UserId)
                {
                }
                column(TIME; Time)
                {
                }
                column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
                {
                }
                column(STRSUBSTNO_Text000_Contrato__No___; StrSubstNo(Text000, Contrato."No."))
                {
                }
                column(CompanyInformation_Name; CompanyInformation.Name)
                {
                }
                column(BudgetOptionText; BudgetOptionText)
                {
                }
                column(Contrato_Task___No__of_Blank_Lines_; "Contrato Task"."No. of Blank Lines")
                {
                }
                column(PageGroupNo; PageGroupNo)
                {
                }
                column(PrintToExcel; PrintToExcel)
                {
                }
                column(Contrato_TABLECAPTION_____Filters______ContratoFilter; Contrato.TableCaption + ' Filters: ' + ContratoFilter)
                {
                }
                column(ContratoFilter; ContratoFilter)
                {
                }
                column(Contrato_Task__TABLECAPTION_____Filters______ContratoTaskFilter; "Contrato Task".TableCaption + ' Filters: ' + ContratoTaskFilter)
                {
                }
                column(ContratoTaskFilter; ContratoTaskFilter)
                {
                }
                column(Contrato__Description_2_; Contrato."Description 2")
                {
                }
                column(Contrato_FIELDCAPTION__Ending_Date____________FORMAT_Contrato__Ending_Date__; Contrato.FieldCaption("Ending Date") + ': ' + Format(Contrato."Ending Date"))
                {
                }
                column(Contrato_Description; Contrato.Description)
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
                column(VarianceCaption; VarianceCaptionLbl)
                {
                }
                column(ContratoDiffBuff__Budgeted_Total_Cost_Caption; ContratoDiffBuff__Budgeted_Total_Cost_CaptionLbl)
                {
                }
                column(ContratoDiffBuff__Total_Cost_Caption; ContratoDiffBuff__Total_Cost_CaptionLbl)
                {
                }
                column(ContratoDiffBuff__No__Caption; ContratoDiffBuff__No__CaptionLbl)
                {
                }
                column(FORMAT_ContratoDiffBuff_Type_Caption; FORMAT_ContratoDiffBuff_Type_CaptionLbl)
                {
                }
                column(Variance__Caption; Variance__CaptionLbl)
                {
                }
                column(PADSTR____2____Contrato_Task__Indentation_____Contrato_Task__Description_Control1480005Caption; PADSTR____2____Contrato_Task__Indentation_____Contrato_Task__Description_Control1480005CaptionLbl)
                {
                }
                column(Contrato_Task___Contrato_Task_No___Control1480006Caption; Contrato_Task___Contrato_Task_No___Control1480006CaptionLbl)
                {
                }
                column(ContratoDiffBuff_DescriptionCaption; ContratoDiffBuff_DescriptionCaptionLbl)
                {
                }
                dataitem("Contrato Task"; "Contrato Task")
                {
                    DataItemLink = "Contrato No." = field("No.");
                    DataItemLinkReference = Contrato;
                    DataItemTableView = sorting("Contrato No.", "Contrato Task No.");
                    RequestFilterFields = "Contrato Task No.";
                    column(Contrato_Task_Contrato_No_; "Contrato No.")
                    {
                    }
                    column(Contrato_Task_Contrato_Task_No_; "Contrato Task No.")
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
                    dataitem("Contrato Planning Line"; "Contrato Planning Line")
                    {
                        DataItemLink = "Contrato No." = field("No."), "Planning Date" = field("Planning Date Filter");
                        DataItemLinkReference = Contrato;
                        DataItemTableView = sorting("Contrato No.", "Contrato Task No.", "Schedule Line", "Planning Date") where(Type = filter(<> Text));

                        trigger OnAfterGetRecord()
                        begin
                            Contrato.SetContratoDiffBuff(
                              ContratoDiffBuff, "Contrato No.", "Contrato Task"."Contrato Task No.", "Contrato Task"."Contrato Task Type".AsInteger(), Type.AsInteger(), "No.",
                              "Location Code", "Variant Code", "Unit of Measure Code", "Work Type Code");
                            ContratoDiffBuff."Unit of Measure code" := '';

                            if ContratoDiffBuff.Find() then begin
                                ContratoDiffBuff."Budgeted Total Cost" := ContratoDiffBuff."Budgeted Total Cost" + "Total Cost (LCY)";
                                ContratoDiffBuff.Modify();
                            end else begin
                                if "Contrato Task"."Contrato Task Type" = "Contrato Task"."Contrato Task Type"::Posting then
                                    ContratoDiffBuff.Description := GetItemDescription(Type.AsInteger(), "No.");
                                ContratoDiffBuff."Budgeted Total Cost" := "Total Cost (LCY)";
                                ContratoDiffBuff.Insert();
                            end;
                        end;

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
                    dataitem("Contrato Ledger Entry"; "Contrato Ledger Entry")
                    {
                        DataItemLink = "Contrato No." = field("No."), "Posting Date" = field("Posting Date Filter");
                        DataItemLinkReference = Contrato;
                        DataItemTableView = sorting("Contrato No.", "Contrato Task No.", "Entry Type", "Posting Date") where("Entry Type" = const(Usage));

                        trigger OnAfterGetRecord()
                        begin
                            Contrato.SetContratoDiffBuff(
                              ContratoDiffBuff, "Contrato No.", "Contrato Task"."Contrato Task No.", "Contrato Task"."Contrato Task Type".AsInteger(), Type.AsInteger(), "No.",
                              "Location Code", "Variant Code", "Unit of Measure Code", "Work Type Code");
                            ContratoDiffBuff."Unit of Measure code" := '';

                            if ContratoDiffBuff.Find() then begin
                                ContratoDiffBuff."Total Cost" := ContratoDiffBuff."Total Cost" + "Total Cost (LCY)";
                                ContratoDiffBuff.Modify();
                            end else begin
                                if "Contrato Task"."Contrato Task Type" = "Contrato Task"."Contrato Task Type"::Posting then
                                    ContratoDiffBuff.Description := GetItemDescription(Type.AsInteger(), "No.");
                                ContratoDiffBuff."Total Cost" := "Total Cost (LCY)";
                                ContratoDiffBuff.Insert();
                            end;
                        end;

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
                        end;
                    }
                    dataitem("Integer"; "Integer")
                    {
                        DataItemTableView = sorting(Number);
                        column(PADSTR____2____Contrato_Task__Indentation_____Contrato_Task__Description; PadStr('', 2 * "Contrato Task".Indentation) + "Contrato Task".Description)
                        {
                        }
                        column(Contrato_Task___Contrato_Task_No__; "Contrato Task"."Contrato Task No.")
                        {
                        }
                        column(Contrato_Task___Contrato_Task_Type__IN; "Contrato Task"."Contrato Task Type" in ["Contrato Task"."Contrato Task Type"::Heading, "Contrato Task"."Contrato Task Type"::"Begin-Total"])
                        {
                        }
                        column(Contrato__No__; Contrato."No.")
                        {
                        }
                        column(PADSTR____2____Contrato_Task__Indentation_____Contrato_Task__Description_Control1480005; PadStr('', 2 * "Contrato Task".Indentation) + "Contrato Task".Description)
                        {
                        }
                        column(Contrato_Task___Contrato_Task_No___Control1480006; "Contrato Task"."Contrato Task No.")
                        {
                        }
                        column(ContratoDiffBuff__Total_Cost_; ContratoDiffBuff."Total Cost")
                        {
                            AutoFormatType = 1;
                        }
                        column(ContratoDiffBuff__Budgeted_Total_Cost_; ContratoDiffBuff."Budgeted Total Cost")
                        {
                            AutoFormatType = 1;
                        }
                        column(Variance; Variance)
                        {
                            AutoFormatType = 1;
                        }
                        column(Variance__; "Variance%")
                        {
                            DecimalPlaces = 1 : 1;
                        }
                        column(FORMAT_ContratoDiffBuff_Type_; Format(ContratoDiffBuff.Type))
                        {
                        }
                        column(ContratoDiffBuff__No__; ContratoDiffBuff."No.")
                        {
                        }
                        column(ContratoDiffBuff_Description; ContratoDiffBuff.Description)
                        {
                        }
                        column(Contrato_Task___Contrato_Task_Type_____Contrato_Task___Contrato_Task_Type___Posting; "Contrato Task"."Contrato Task Type" = "Contrato Task"."Contrato Task Type"::Posting)
                        {
                        }
                        column(PADSTR____2____Contrato_Task__Indentation_____Contrato_Task__Description_Control1480007; PadStr('', 2 * "Contrato Task".Indentation) + "Contrato Task".Description)
                        {
                        }
                        column(Contrato_Task___Contrato_Task_No___Control1480008; "Contrato Task"."Contrato Task No.")
                        {
                        }
                        column(ContratoDiffBuff__Total_Cost__Control1480013; ContratoDiffBuff."Total Cost")
                        {
                            AutoFormatType = 1;
                        }
                        column(ContratoDiffBuff__Budgeted_Total_Cost__Control1480014; ContratoDiffBuff."Budgeted Total Cost")
                        {
                            AutoFormatType = 1;
                        }
                        column(Variance_Control1480015; Variance)
                        {
                            AutoFormatType = 1;
                        }
                        column(Variance___Control1480016; "Variance%")
                        {
                            DecimalPlaces = 1 : 1;
                        }
                        column(Contrato_Task___Contrato_Task_Type__IN___Contrato_Task___Contrato_Task_Type___Total; "Contrato Task"."Contrato Task Type" in ["Contrato Task"."Contrato Task Type"::Total, "Contrato Task"."Contrato Task Type"::"End-Total"])
                        {
                        }
                        column(Integer_Number; Number)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            case Number of
                                0:
                                    exit;
                                1:
                                    ContratoDiffBuff.Find('-');
                                else
                                    ContratoDiffBuff.Next();
                            end;

                            Variance := ContratoDiffBuff."Total Cost" - ContratoDiffBuff."Budgeted Total Cost";
                            if ContratoDiffBuff."Budgeted Total Cost" = 0 then
                                "Variance%" := 0
                            else
                                "Variance%" := 100 * Variance / ContratoDiffBuff."Budgeted Total Cost";

                            if PrintToExcel then
                                MakeExcelDataBody();
                        end;

                        trigger OnPreDataItem()
                        begin
                            ContratoDiffBuff.Reset();
                            ContratoDiffBuff.SetRange("Contrato No.", "Contrato Task"."Contrato No.");
                            ContratoDiffBuff.SetRange("Contrato Task No.", "Contrato Task"."Contrato Task No.");
                            if "Contrato Task"."Contrato Task Type" in ["Contrato Task"."Contrato Task Type"::Heading, "Contrato Task"."Contrato Task Type"::"Begin-Total"] then
                                SetRange(Number, 0, ContratoDiffBuff.Count)
                            else
                                SetRange(Number, 1, ContratoDiffBuff.Count)
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        ContratoDiffBuff.Reset();

                        PageGroupNo := NextPageGroupNo;
                        if "New Page" then
                            NextPageGroupNo := PageGroupNo + 1;
                    end;
                }
            }

            trigger OnAfterGetRecord()
            begin
                ContratoDiffBuff.DeleteAll();

                if PrintToExcel then
                    MakeExcelInfo();
            end;

            trigger OnPostDataItem()
            begin
                if PrintToExcel then
                    CreateExcelbook();
            end;

            trigger OnPreDataItem()
            begin
                if (Count > 1) and PrintToExcel then
                    Error(Text003);
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
                        ApplicationArea = Contratos;
                        Caption = 'Budget Amounts Per';
                        OptionCaption = 'Budget,Billable';
                        ToolTip = 'Specifies if the budget amounts must be based on budgets or billables.';
                    }
                    field(PrintToExcel; PrintToExcel)
                    {
                        ApplicationArea = Contratos;
                        Caption = 'Print to Excel';
                        ToolTip = 'Specifies if you want to export the data to an Excel spreadsheet for additional analysis or formatting before printing.';
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
        ContratoTaskFilter := "Contrato Task".GetFilters();
        if BudgetAmountsPer = BudgetAmountsPer::Schedule then
            BudgetOptionText := Text001
        else
            BudgetOptionText := Text002;
    end;

    var
        CompanyInformation: Record "Company Information";
        ContratoDiffBuff: Record "Contrato Difference Buffer" temporary;
        ExcelBuf: Record "Excel Buffer" temporary;
        ContratoFilter: Text;
        ContratoTaskFilter: Text;
        Variance: Decimal;
        "Variance%": Decimal;
        Text000: Label 'Actual Cost to Budget Cost for Project %1';
        Text001: Label 'Budgeted Amounts are per the Budget';
        Text002: Label 'Budgeted Amounts are per the Contract';
        BudgetAmountsPer: Option Schedule,Contract;
        BudgetOptionText: Text[50];
        PrintToExcel: Boolean;
        Text003: Label 'When printing to Excel, you must select only one Project.';
        Text101: Label 'Data';
        Text102: Label 'Project Actual to Budget (Cost)';
        Text103: Label 'Company Name';
        Text104: Label 'Report No.';
        Text105: Label 'Report Name';
        Text106: Label 'User ID';
        Text107: Label 'Date / Time';
        Text108: Label 'Project Filters';
        Text109: Label 'Project Task Filters';
        Text110: Label 'Variance';
        Text111: Label 'Percent Variance';
        Text112: Label 'Budget Option';
        Text113: Label 'Project Information:';
        Text114: Label 'Starting / Ending Dates';
        Text115: Label 'Actual Total Cost';
        PageGroupNo: Integer;
        NextPageGroupNo: Integer;
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Contrato_DescriptionCaptionLbl: Label 'Project Description';
        VarianceCaptionLbl: Label 'Variance';
        ContratoDiffBuff__Budgeted_Total_Cost_CaptionLbl: Label 'Budgeted Total Cost';
        ContratoDiffBuff__Total_Cost_CaptionLbl: Label 'Actual Total Cost';
        ContratoDiffBuff__No__CaptionLbl: Label 'No.';
        FORMAT_ContratoDiffBuff_Type_CaptionLbl: Label 'Type';
        Variance__CaptionLbl: Label 'Percent Variance';
        PADSTR____2____Contrato_Task__Indentation_____Contrato_Task__Description_Control1480005CaptionLbl: Label 'Project Task Description';
        Contrato_Task___Contrato_Task_No___Control1480006CaptionLbl: Label 'Project Task No.';
        ContratoDiffBuff_DescriptionCaptionLbl: Label 'Description';

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

    local procedure MakeExcelInfo()
    begin
        ExcelBuf.SetUseInfoSheet();
        ExcelBuf.AddInfoColumn(Format(Text103), false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(CompanyInformation.Name, false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow();
        ExcelBuf.AddInfoColumn(Format(Text105), false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(StrSubstNo(Text000, Contrato."No."), false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow();
        ExcelBuf.AddInfoColumn(Format(Text104), false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(REPORT::"ContratoActualtoBudget(Cost)", false, false, false, false, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.NewRow();
        ExcelBuf.AddInfoColumn(Format(Text106), false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(UserId, false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow();
        ExcelBuf.AddInfoColumn(Format(Text107), false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(Today, false, false, false, false, '', ExcelBuf."Cell Type"::Date);
        ExcelBuf.AddInfoColumn(Time, false, false, false, false, '', ExcelBuf."Cell Type"::Time);
        ExcelBuf.NewRow();
        ExcelBuf.AddInfoColumn(Format(Text112), false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(BudgetOptionText, false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow();
        ExcelBuf.AddInfoColumn(Format(Text108), false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(ContratoFilter, false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow();
        ExcelBuf.AddInfoColumn(Format(Text109), false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(ContratoTaskFilter, false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow();
        ExcelBuf.AddInfoColumn(Format(Text113), false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow();
        ExcelBuf.AddInfoColumn(
          '  ' + Contrato.TableCaption + ' ' + Contrato.FieldCaption("No."), false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(Contrato."No.", false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow();
        ExcelBuf.AddInfoColumn('  ' + Contrato.FieldCaption(Description), false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(Contrato.Description + ' ' + Contrato."Description 2", false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow();
        ExcelBuf.AddInfoColumn('  ' + Format(Text114), false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(Format(Contrato."Starting Date"), false, false, false, false, '', ExcelBuf."Cell Type"::Date);
        ExcelBuf.AddInfoColumn(Format(Contrato."Ending Date"), false, false, false, false, '', ExcelBuf."Cell Type"::Date);
        ExcelBuf.ClearNewRow();
        MakeExcelDataHeader();
    end;

    local procedure MakeExcelDataHeader()
    begin
        ExcelBuf.NewRow();
        ExcelBuf.AddColumn("Contrato Task".FieldCaption("Contrato Task No."), false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(
          "Contrato Task".TableCaption + ' ' + "Contrato Task".FieldCaption(Description), false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(ContratoDiffBuff.FieldCaption(Type), false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(ContratoDiffBuff.FieldCaption("No."), false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(ContratoDiffBuff.FieldCaption(Description), false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(Format(Text115), false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(ContratoDiffBuff.FieldCaption("Budgeted Total Cost"), false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(Format(Text110), false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(Format(Text111), false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
    end;

    local procedure MakeExcelDataBody()
    begin
        ExcelBuf.NewRow();
        ExcelBuf.AddColumn("Contrato Task"."Contrato Task No.", false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        case "Contrato Task"."Contrato Task Type" of
            "Contrato Task"."Contrato Task Type"::Heading, "Contrato Task"."Contrato Task Type"::"Begin-Total":
                ExcelBuf.AddColumn(
                  PadStr('', 2 * "Contrato Task".Indentation) + "Contrato Task".Description, false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);
            "Contrato Task"."Contrato Task Type"::Posting:
                begin
                    ExcelBuf.AddColumn(
                      PadStr('', 2 * "Contrato Task".Indentation) + "Contrato Task".Description, false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                    ExcelBuf.AddColumn(Format(ContratoDiffBuff.Type), false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                    ExcelBuf.AddColumn(ContratoDiffBuff."No.", false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                    ExcelBuf.AddColumn(ContratoDiffBuff.Description, false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                    ExcelBuf.AddColumn(ContratoDiffBuff."Total Cost", false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
                    ExcelBuf.AddColumn(ContratoDiffBuff."Budgeted Total Cost", false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
                    ExcelBuf.AddColumn(Variance, false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
                    ExcelBuf.AddColumn("Variance%" / 100, false, '', false, false, false, '0.0%', ExcelBuf."Cell Type"::Number);
                end;
            "Contrato Task"."Contrato Task Type"::Total, "Contrato Task"."Contrato Task Type"::"End-Total":
                begin
                    ExcelBuf.AddColumn(
                      PadStr('', 2 * "Contrato Task".Indentation) + "Contrato Task".Description, false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);
                    ExcelBuf.AddColumn('', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                    ExcelBuf.AddColumn('', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                    ExcelBuf.AddColumn('', false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                    ExcelBuf.AddColumn(ContratoDiffBuff."Total Cost", false, '', true, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
                    ExcelBuf.AddColumn(ContratoDiffBuff."Budgeted Total Cost", false, '', true, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
                    ExcelBuf.AddColumn(Variance, false, '', true, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
                    ExcelBuf.AddColumn("Variance%" / 100, false, '', true, false, false, '0.0%', ExcelBuf."Cell Type"::Number);
                end;
        end;
    end;

    local procedure CreateExcelbook()
    begin
        //ExcelBuf.CreateBookAndOpenExcel('', Text101, Text102, CompanyName, UserId);
        Error('');
    end;
}

