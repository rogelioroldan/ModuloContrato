report 50207 "Contrato Actual To Budget"
{
    AdditionalSearchTerms = 'Contrato Actual To Budget';
    DefaultLayout = RDLC;
    RDLCLayout = './Contratos/Contrato/Reports/ContratoActualToBudget.rdlc';
    ApplicationArea = Contratos;
    Caption = 'Contrato Actual To Budget';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Contrato; Contrato)
        {
            RequestFilterFields = "No.", "Posting Date Filter", "Planning Date Filter";
            column(TodayFormatted; Format(Today, 0, 4))
            {
            }
            column(CompanyName; COMPANYPROPERTY.DisplayName())
            {
            }
            column(ContratoTableCaptionFilter; TableCaption + ': ' + ContratoFilter)
            {
            }
            column(ContratoFilter; ContratoFilter)
            {
            }
            column(ContratoTaskTableCaptionFilter; "Contrato Task".TableCaption + ': ' + ContratoTaskFilter)
            {
            }
            column(ContratoTaskFilter; ContratoTaskFilter)
            {
            }
            column(EmptyString; '')
            {
            }
            column(ContratoCalcBatchesCurrencyField; ContratoCalcBatches.GetCurrencyCode(Contrato, 0, CurrencyFieldReq))
            {
            }
            column(ContratoCalcBatches3CurrencyField; ContratoCalcBatches.GetCurrencyCode(Contrato, 3, CurrencyFieldReq))
            {
            }
            column(No_Contrato; "No.")
            {
            }
            column(CurrReportPageNoCaption; CurrReportPageNoCaptionLbl)
            {
            }
            column(ContratoActualToBudgetCaption; ContratoActualToBudgetCaptionLbl)
            {
            }
            column(QuantityCaption; QuantityCaptionLbl)
            {
            }
            column(ScheduleCaption; ScheduleCaptionLbl)
            {
            }
            column(UsageCaption; UsageCaptionLbl)
            {
            }
            column(DifferenceCaption; DifferenceCaptionLbl)
            {
            }
            dataitem("Contrato Task"; "Contrato Task")
            {
                DataItemLink = "Contrato No." = field("No.");
                DataItemTableView = sorting("Contrato No.", "Contrato Task No.");
                RequestFilterFields = "Contrato Task No.";
                column(Desc_Contrato; Contrato.Description)
                {
                }
                column(ContratoTaskNo_ContratoTask; "Contrato Task No.")
                {
                }
                column(Description_ContratoTask; Description)
                {
                }
                column(ContratoTaskNoCaption; ContratoTaskNoCaptionLbl)
                {
                }
                dataitem(FirstBuffer; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                    column(Amt1; Amt[1])
                    {
                        DecimalPlaces = 0 : 5;
                    }
                    column(Amt2; Amt[2])
                    {
                        DecimalPlaces = 0 : 5;
                    }
                    column(Amt3; Amt[3])
                    {
                        DecimalPlaces = 0 : 5;
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
                    column(Amt9; Amt[9])
                    {
                    }
                    column(ContratoDiffBufferType1; TempContratoDiffBuffer.Type)
                    {
                    }
                    column(ContratoDiffBufferNo; TempContratoDiffBuffer."No.")
                    {
                    }
                    column(ContratoDiffBufferUOMcode; TempContratoDiffBuffer."Unit of Measure code")
                    {
                    }
                    column(ContratoDiffBufferWorkTypeCode; TempContratoDiffBuffer."Work Type Code")
                    {
                    }
                    column(ShowFirstBuffer; ShowFirstBuffer)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        Clear(ShowFirstBuffer);

                        Clear(Amt);
                        if Number = 1 then begin
                            if not TempContratoDiffBuffer.Find('-') then
                                CurrReport.Break();
                        end else
                            if TempContratoDiffBuffer.Next() = 0 then
                                CurrReport.Break();
                        Amt[1] := TempContratoDiffBuffer.Quantity;
                        Amt[4] := TempContratoDiffBuffer."Total Cost";
                        Amt[7] := TempContratoDiffBuffer."Line Amount";

                        TempContratoDiffBuffer2 := TempContratoDiffBuffer;
                        if TempContratoDiffBuffer2.Find() then begin
                            Amt[2] := TempContratoDiffBuffer2.Quantity;
                            Amt[5] := TempContratoDiffBuffer2."Total Cost";
                            Amt[8] := TempContratoDiffBuffer2."Line Amount";
                            TempContratoDiffBuffer2.Delete();
                        end;
                        Amt[3] := Amt[1] - Amt[2];
                        Amt[6] := Amt[4] - Amt[5];
                        Amt[9] := Amt[7] - Amt[8];

                        PrintContratoTask := false;
                        for I := 1 to 9 do
                            if Amt[I] <> 0 then
                                PrintContratoTask := true;
                        if not PrintContratoTask then
                            CurrReport.Skip();
                        for I := 2 to 9 do begin
                            JTTotalAmt[I] := JTTotalAmt[I] + Amt[I];
                            ContratoTotalAmt[I] := ContratoTotalAmt[I] + Amt[I];
                        end;

                        ShowFirstBuffer := 1;
                    end;
                }
                dataitem(SecondBuffer; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                    column(ContratoDiffBuffer2Type1; TempContratoDiffBuffer2.Type)
                    {
                    }
                    column(ContratoDiffBuffer2No; TempContratoDiffBuffer2."No.")
                    {
                    }
                    column(ContratoDiffBuffer2UOMcode; TempContratoDiffBuffer2."Unit of Measure code")
                    {
                    }
                    column(ContratoDiffBuffer2WorkTypeCode; TempContratoDiffBuffer2."Work Type Code")
                    {
                    }
                    column(Amt12; Amt[1])
                    {
                        DecimalPlaces = 0 : 5;
                    }
                    column(Amt21; Amt[2])
                    {
                        DecimalPlaces = 0 : 5;
                    }
                    column(Amt39; Amt[3])
                    {
                        DecimalPlaces = 0 : 5;
                    }
                    column(Amt40; Amt[4])
                    {
                    }
                    column(Amt55; Amt[5])
                    {
                    }
                    column(Amt66; Amt[6])
                    {
                    }
                    column(Amt77; Amt[7])
                    {
                    }
                    column(Amt88; Amt[8])
                    {
                    }
                    column(Amt99; Amt[9])
                    {
                    }
                    column(ShowSecondBuffer; ShowSecondBuffer)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        Clear(ShowSecondBuffer);

                        Clear(Amt);
                        if Number = 1 then begin
                            if not TempContratoDiffBuffer2.Find('-') then
                                CurrReport.Break();
                        end else
                            if TempContratoDiffBuffer2.Next() = 0 then
                                CurrReport.Break();
                        Amt[2] := TempContratoDiffBuffer2.Quantity;
                        Amt[5] := TempContratoDiffBuffer2."Total Cost";
                        Amt[8] := TempContratoDiffBuffer2."Line Amount";
                        Amt[3] := Amt[1] - Amt[2];
                        Amt[6] := Amt[4] - Amt[5];
                        Amt[9] := Amt[7] - Amt[8];

                        PrintContratoTask := false;
                        for I := 1 to 9 do
                            if Amt[I] <> 0 then
                                PrintContratoTask := true;
                        if not PrintContratoTask then
                            CurrReport.Skip();
                        for I := 2 to 9 do begin
                            JTTotalAmt[I] := JTTotalAmt[I] + Amt[I];
                            ContratoTotalAmt[I] := ContratoTotalAmt[I] + Amt[I];
                        end;

                        ShowSecondBuffer := 2;
                    end;
                }
                dataitem(ContratoTaskTotal; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(JTTotalAmt4; JTTotalAmt[4])
                    {
                    }
                    column(JTTotalAmt5; JTTotalAmt[5])
                    {
                    }
                    column(JTTotalAmt6; JTTotalAmt[6])
                    {
                    }
                    column(JTTotalAmt7; JTTotalAmt[7])
                    {
                    }
                    column(JTTotalAmt8; JTTotalAmt[8])
                    {
                    }
                    column(JTTotalAmt9; JTTotalAmt[9])
                    {
                    }
                    column(ContratoTaskTableCaptionContratoTask; TotalForTxt + ' ' + "Contrato Task".TableCaption + ' ' + "Contrato Task"."Contrato Task No.")
                    {
                    }
                    column(ShowTotalContratoTask; (TotalForTxt + ' ' + "Contrato Task".TableCaption + ' ' + "Contrato Task"."Contrato Task No.") <> '')
                    {
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    if "Contrato Task Type" <> "Contrato Task Type"::Posting then
                        CurrReport.Skip();
                    Clear(ContratoCalcBatches);
                    ContratoCalcBatches.CalculateActualToBudget(
                      Contrato, "Contrato Task", TempContratoDiffBuffer, TempContratoDiffBuffer2, CurrencyFieldReq);
                    if not TempContratoDiffBuffer.Find('-') then
                        if not TempContratoDiffBuffer2.Find('-') then
                            CurrReport.Skip();
                    for I := 1 to 9 do
                        JTTotalAmt[I] := 0;
                end;
            }
            dataitem(ContratoTotal; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                column(ContratoTotalAmt4; ContratoTotalAmt[4])
                {
                }
                column(ContratoTotalAmt5; ContratoTotalAmt[5])
                {
                }
                column(ContratoTotalAmt6; ContratoTotalAmt[6])
                {
                }
                column(ContratoTotalAmt7; ContratoTotalAmt[7])
                {
                }
                column(ContratoTotalAmt8; ContratoTotalAmt[8])
                {
                }
                column(ContratoTotalAmt9; ContratoTotalAmt[9])
                {
                }
                column(ShowTotalContrato; TotalForTxt + ' ' + Contrato.TableCaption + ' ' + Contrato."No." <> '')
                {
                }
                column(ContratoTableCaptionNo_Contrato; TotalForTxt + ' ' + Contrato.TableCaption + ' ' + Contrato."No.")
                {
                }
            }

            trigger OnAfterGetRecord()
            begin
                for I := 1 to 9 do
                    ContratoTotalAmt[I] := 0;
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
        ContratoTaskFilter := "Contrato Task".GetFilters();
    end;

    var
        TempContratoDiffBuffer: Record "Contrato Difference Buffer" temporary;
        TempContratoDiffBuffer2: Record "Contrato Difference Buffer" temporary;
        ContratoCalcBatches: Codeunit "Contrato Calculate Batches";
        Amt: array[9] of Decimal;
        JTTotalAmt: array[9] of Decimal;
        ContratoTotalAmt: array[9] of Decimal;
        CurrencyFieldReq: Option "Local Currency","Foreign Currency";
        ContratoFilter: Text;
        ContratoTaskFilter: Text;
        PrintContratoTask: Boolean;
        I: Integer;
        TotalForTxt: Label 'Total for';
        ShowFirstBuffer: Integer;
        ShowSecondBuffer: Integer;
        CurrReportPageNoCaptionLbl: Label 'Page';
        ContratoActualToBudgetCaptionLbl: Label 'Contrato Actual To Budget';
        QuantityCaptionLbl: Label 'Quantity';
        ScheduleCaptionLbl: Label 'Budget';
        UsageCaptionLbl: Label 'Usage';
        DifferenceCaptionLbl: Label 'Difference';
        ContratoTaskNoCaptionLbl: Label 'Contrato Task No.';

    procedure InitializeRequest(NewCurrencyField: Option "Local Currency","Foreign Currency")
    begin
        CurrencyFieldReq := NewCurrencyField;
    end;
}

