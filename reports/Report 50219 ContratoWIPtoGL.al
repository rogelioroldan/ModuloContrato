report 50219 "Contrato WIP To G/L"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Contratos/Contrato/Reports/ContratoWIPToGL.rdlc';
    AdditionalSearchTerms = 'work in process to general ledger,work in progress to general ledger, Contrato WIP To G/L';
    ApplicationArea = Contratos;
    Caption = 'Contrato WIP To G/L';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Contrato; Contrato)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Posting Date Filter";
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(Contrato_TABLECAPTION__________ContratoFilter; TableCaption + ': ' + ContratoFilter)
            {
            }
            column(ContratoFilter; ContratoFilter)
            {
            }
            column(Contrato_WIP_To_G_LCaption; Contrato_WIP_To_G_LCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(G_L_Acc__No_Caption; G_L_Acc__No_CaptionLbl)
            {
            }
            column(DescriptionCaption; DescriptionCaptionLbl)
            {
            }
            column(Contrato_Posting_GroupCaption; Contrato_Posting_GroupCaptionLbl)
            {
            }
            column(AccountCaption; AccountCaptionLbl)
            {
            }
            column(WIP_AmountCaption; WIP_AmountCaptionLbl)
            {
            }
            column(G_L_BalanceCaption; G_L_BalanceCaptionLbl)
            {
            }
            column(DifferenceCaption; DifferenceCaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                TempContratoBuffer2.InsertWorkInProgress(Contrato);
            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = sorting(Number) where(Number = filter(1 ..));
            column(GLAcc__No__; GLAcc."No.")
            {
            }
            column(ContratoBuffer__Amount_1_; TempContratoBuffer."Amount 1")
            {
            }
            column(ContratoBuffer__Account_No__2_; TempContratoBuffer."Account No. 2")
            {
            }
            column(GLAcc_Name; GLAcc.Name)
            {
            }
            column(WIPText; WIPText)
            {
            }
            column(WIPText1; WIPText1)
            {
            }
            column(ContratoBuffer__Amount_2_; TempContratoBuffer."Amount 2")
            {
            }
            column(WIPText2; WIPText2)
            {
            }
            column(ContratoBuffer__Amount_4_; TempContratoBuffer."Amount 4")
            {
            }
            column(WIPText3; WIPText3)
            {
            }
            column(ContratoBuffer__Amount_5_; TempContratoBuffer."Amount 5")
            {
            }
            column(WIPText4; WIPText4)
            {
            }
            column(GLAccContratoTotal; GLAccContratoTotal)
            {
            }
            column(ContratoBuffer__Amount_3_; TempContratoBuffer."Amount 3")
            {
            }
            column(GLAccContratoTotal___ContratoBuffer__Amount_3_; GLAccContratoTotal - TempContratoBuffer."Amount 3")
            {
            }
            column(NewTotal; TempContratoBuffer."New Total")
            {
            }
            column(GLContratoTotal; GLContratoTotal)
            {
            }
            column(GLTotal; GLTotal)
            {
            }
            column(GLContratoTotal___GLTotal; GLContratoTotal - GLTotal)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
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
                GLAcc.Name := '';
                GLAcc."No." := '';

                if OldAccNo <> TempContratoBuffer."Account No. 1" then begin
                    if GLAcc.Get(TempContratoBuffer."Account No. 1") then;
                    GLAccContratoTotal := 0;
                end;
                OldAccNo := TempContratoBuffer."Account No. 1";
                GLAccContratoTotal := GLAccContratoTotal + TempContratoBuffer."Amount 1" + TempContratoBuffer."Amount 2" + TempContratoBuffer."Amount 4" + TempContratoBuffer."Amount 5";
                GLContratoTotal := GLContratoTotal + TempContratoBuffer."Amount 1" + TempContratoBuffer."Amount 2" + TempContratoBuffer."Amount 4" + TempContratoBuffer."Amount 5";
                if TempContratoBuffer."New Total" then
                    GLTotal := GLTotal + TempContratoBuffer."Amount 3";

                if TempContratoBuffer."Amount 1" <> 0 then
                    WIPText1 := SelectStr(1, TEXT000);
                if TempContratoBuffer."Amount 2" <> 0 then
                    WIPText2 := SelectStr(2, TEXT000);
                if TempContratoBuffer."Amount 4" <> 0 then
                    WIPText3 := SelectStr(4, TEXT000);
                if TempContratoBuffer."Amount 5" <> 0 then
                    WIPText4 := SelectStr(3, TEXT000);
            end;

            trigger OnPreDataItem()
            begin
                TempContratoBuffer2.GetContratoBuffer(Contrato, TempContratoBuffer);
                OldAccNo := '';
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
        TempContratoBuffer2.InitContratoBuffer();
        ContratoFilter := Contrato.GetFilters();
    end;

    var
        TempContratoBuffer: Record "Contrato Buffer" temporary;
        TempContratoBuffer2: Record "Contrato Buffer" temporary;
        GLAcc: Record "G/L Account";
        ContratoFilter: Text;
        WIPText: Text[50];
        TEXT000: Label 'WIP Cost Amount,WIP Accrued Costs Amount,WIP Accrued Sales Amount,WIP Invoiced Sales Amount';
        WIPText1: Text[50];
        WIPText2: Text[50];
        WIPText3: Text[50];
        WIPText4: Text[50];
        OldAccNo: Code[20];
        GLAccContratoTotal: Decimal;
        GLContratoTotal: Decimal;
        GLTotal: Decimal;
        Contrato_WIP_To_G_LCaptionLbl: Label 'Contrato WIP To G/L';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        G_L_Acc__No_CaptionLbl: Label 'G/L Acc. No.';
        DescriptionCaptionLbl: Label 'Description';
        Contrato_Posting_GroupCaptionLbl: Label 'Contrato Posting Group';
        AccountCaptionLbl: Label 'Account';
        WIP_AmountCaptionLbl: Label 'WIP Amount';
        G_L_BalanceCaptionLbl: Label 'G/L Balance';
        DifferenceCaptionLbl: Label 'Difference';
        TotalCaptionLbl: Label 'Total';
}

