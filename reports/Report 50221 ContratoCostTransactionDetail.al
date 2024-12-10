report 50221 "ContratoCostTransactionDetail"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Local/Contratos/Contrato/Reports/ContratoCostTransactionDetail.rdlc';
    ApplicationArea = All;
    Caption = 'Contrato Cost Transaction Detail';
    AdditionalSearchTerms = 'Contrato Cost Transaction Detail';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Contrato; Contrato)
        {
            DataItemTableView = sorting("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", Status, "Posting Date Filter";
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(TIME; Time)
            {
            }
            column(CompanyInformation_Name; CompanyInformation.Name)
            {
            }
            column(USERID; UserId)
            {
            }
            column(Contrato_TABLECAPTION__________ContratoFilter; Contrato.TableCaption + ': ' + ContratoFilter)
            {
            }
            column(ContratoFilter; ContratoFilter)
            {
            }
            column(TABLECAPTION_________FIELDCAPTION__No_____________No__; TableCaption + ' ' + FieldCaption("No.") + ' ' + "No.")
            {
            }
            column(Contrato_Description; Description)
            {
            }
            column(Contrato_No_; "No.")
            {
            }
            column(Contrato_Posting_Date_Filter; "Posting Date Filter")
            {
            }
            column(Contrato_Cost_Transaction_DetailCaption; Contrato_Cost_Transaction_DetailCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Contrato_Ledger_Entry__Posting_Date_Caption; "Contrato Ledger Entry".FieldCaption("Posting Date"))
            {
            }
            column(Contrato_Ledger_Entry_TypeCaption; "Contrato Ledger Entry".FieldCaption(Type))
            {
            }
            column(Contrato_Ledger_Entry__Document_No__Caption; "Contrato Ledger Entry".FieldCaption("Document No."))
            {
            }
            column(Contrato_Ledger_Entry__Entry_Type_Caption; "Contrato Ledger Entry".FieldCaption("Entry Type"))
            {
            }
            column(Contrato_Ledger_Entry__No__Caption; "Contrato Ledger Entry".FieldCaption("No."))
            {
            }
            column(Contrato_Ledger_Entry_QuantityCaption; "Contrato Ledger Entry".FieldCaption(Quantity))
            {
            }
            column(Contrato_Ledger_Entry__Unit_of_Measure_Code_Caption; "Contrato Ledger Entry".FieldCaption("Unit of Measure Code"))
            {
            }
            column(Contrato_Ledger_Entry__Total_Cost__LCY__Caption; "Contrato Ledger Entry".FieldCaption("Total Cost (LCY)"))
            {
            }
            column(Contrato_Ledger_Entry__Total_Price__LCY__Caption; "Contrato Ledger Entry".FieldCaption("Total Price (LCY)"))
            {
            }
            column(Contrato_Ledger_Entry__Amt__Posted_to_G_L_Caption; "Contrato Ledger Entry".FieldCaption("Amt. Posted to G/L"))
            {
            }
            column(Contrato_Ledger_Entry__Amt__Recognized_Caption; Contrato_Ledger_Entry__Amt__Recognized_CaptionLbl)
            {
            }
            dataitem("Contrato Ledger Entry"; "Contrato Ledger Entry")
            {
                DataItemLink = "Contrato No." = field("No."), "Posting Date" = field("Posting Date Filter");
                DataItemTableView = sorting("Contrato No.", "Posting Date");
                column(Contrato_Ledger_Entry__Posting_Date_; "Posting Date")
                {
                }
                column(Contrato_Ledger_Entry_Type; Type)
                {
                }
                column(Contrato_Ledger_Entry__Document_No__; "Document No.")
                {
                }
                column(Contrato_Ledger_Entry__Entry_Type_; "Entry Type")
                {
                }
                column(Contrato_Ledger_Entry__No__; "No.")
                {
                }
                column(Contrato_Ledger_Entry_Quantity; Quantity)
                {
                    DecimalPlaces = 2 : 5;
                }
                column(Contrato_Ledger_Entry__Unit_of_Measure_Code_; "Unit of Measure Code")
                {
                }
                column(Contrato_Ledger_Entry__Total_Cost__LCY__; "Total Cost (LCY)")
                {
                }
                column(Contrato_Ledger_Entry__Total_Price__LCY__; "Total Price (LCY)")
                {
                }
                column(Contrato_Ledger_Entry__Amt__Posted_to_G_L_; "Amt. Posted to G/L")
                {
                }
                column(TotalCost_1_; TotalCost[1])
                {
                }
                column(TotalPrice_1_; TotalPrice[1])
                {
                }
                column(AmtPostedToGL_1_; AmtPostedToGL[1])
                {
                }
                column(STRSUBSTNO_Text000_FIELDCAPTION__Contrato_No_____Contrato_No___; StrSubstNo(Text000, FieldCaption("Contrato No."), "Contrato No."))
                {
                }
                column(STRSUBSTNO_Text001_FIELDCAPTION__Contrato_No_____Contrato_No___; StrSubstNo(Text001, FieldCaption("Contrato No."), "Contrato No."))
                {
                }
                column(TotalCost_2_; TotalCost[2])
                {
                }
                column(TotalPrice_2_; TotalPrice[2])
                {
                }
                column(AmtPostedToGL_2_; AmtPostedToGL[2])
                {
                }
                column(Contrato_Ledger_Entry_Entry_No_; "Entry No.")
                {
                }
                column(Contrato_Ledger_Entry_Contrato_No_; "Contrato No.")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    IncrementTotals("Entry Type".AsInteger());
                end;

                trigger OnPreDataItem()
                begin
                    Clear(TotalCost);
                    Clear(TotalPrice);
                    Clear(AmtPostedToGL);
                end;
            }
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
        CompanyInformation.Get();
        ContratoFilter := Contrato.GetFilters();
    end;

    var
        CompanyInformation: Record "Company Information";
        ContratoFilter: Text;
        TotalCost: array[2] of Decimal;
        TotalPrice: array[2] of Decimal;
        AmtPostedToGL: array[2] of Decimal;
        Text000: Label 'Total Usage for %1 %2';
        Text001: Label 'Total Sales for %1 %2';
        Contrato_Cost_Transaction_DetailCaptionLbl: Label 'Contrato Cost Transaction Detail';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Contrato_Ledger_Entry__Amt__Recognized_CaptionLbl: Label 'Contrato Ledger Entry - Amt. Recognized';

    procedure IncrementTotals(EntryType: Integer)
    var
        i: Integer;
    begin
        i := EntryType + 1;
        TotalCost[i] := TotalCost[i] + "Contrato Ledger Entry"."Total Cost (LCY)";
        TotalPrice[i] := TotalPrice[i] + "Contrato Ledger Entry"."Total Price (LCY)";
        AmtPostedToGL[i] := AmtPostedToGL[i] + "Contrato Ledger Entry"."Amt. Posted to G/L";
        // AmtRecognized[i] := AmtRecognized[i] + "Contrato Ledger Entry"."Amt. Recognized";
    end;
}

