page 50207 "Contr WIP/Recognition FactBox"
{
    Caption = 'Contrato Details - WIP/Recognition';
    PageType = CardPart;
    SourceTable = Contrato;

    layout
    {
        area(content)
        {
            field("No."; Rec."No.")
            {
                ApplicationArea = All;
                Caption = 'Contrato No.';
                ToolTip = 'Specifies the contrato number.';

                trigger OnDrillDown()
                begin
                    ShowDetails();
                end;
            }
            field("WIP Posting Date"; Rec."WIP Posting Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the posting date that was entered when the Contrato Calculate WIP batch Contrato was last run.';
            }
            field("Total WIP Cost Amount"; Rec."Total WIP Cost Amount")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the total WIP cost amount that was last calculated for the contrato. The WIP Cost Amount for the contrato is the value WIP Cost Contrato WIP Entries less the value of the Recognized Cost Contrato WIP Entries. For contratos with WIP Methods of Sales Value or Percentage of Completion, the WIP Cost Amount is normally 0.';
            }
            field("Applied Costs G/L Amount"; Rec."Applied Costs G/L Amount")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the sum of all applied costs of the selected contrato.';
                Visible = false;
            }
            field("Total WIP Sales Amount"; Rec."Total WIP Sales Amount")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the total WIP Sales amount that was last calculated for the contrato. The WIP Sales Amount for the contrato is the value WIP Sales Contrato WIP Entries less the value of the Recognized Sales Contrato WIP Entries. For contratos with WIP Methods of Cost Value or Cost of Sales, the WIP Sales Amount is normally 0.';
            }
            field("Applied Sales G/L Amount"; Rec."Applied Sales G/L Amount")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the sum of all applied costs of the selected contrato.';
                Visible = false;
            }
            field("Recog. Costs Amount"; Rec."Recog. Costs Amount")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Recognized Cost amount that was last calculated for the contrato. The Recognized Cost Amount for the contrato is the sum of the Recognized Cost Contrato WIP Entries.';
            }
            field("Recog. Sales Amount"; Rec."Recog. Sales Amount")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the recognized sales amount that was last calculated for the contrato, which is the sum of the Recognized Sales Contrato WIP Entries.';
            }
            field("Recog. Profit Amount"; Rec.CalcRecognizedProfitAmount())
            {
                ApplicationArea = All;
                Caption = 'Recog. Profit Amount';
                ToolTip = 'Specifies the recognized profit amount for the contrato.';
            }
            field("Recog. Profit %"; Rec.CalcRecognizedProfitPercentage())
            {
                ApplicationArea = All;
                Caption = 'Recog. Profit %';
                ToolTip = 'Specifies the recognized profit percentage for the contrato.';
            }
            field("Acc. WIP Costs Amount"; Rec.CalcAccWIPCostsAmount())
            {
                ApplicationArea = All;
                Caption = 'Acc. WIP Costs Amount';
                ToolTip = 'Specifies the total WIP costs for the contrato.';
                Visible = false;
            }
            field("Acc. WIP Sales Amount"; Rec.CalcAccWIPSalesAmount())
            {
                ApplicationArea = All;
                Caption = 'Acc. WIP Sales Amount';
                ToolTip = 'Specifies the total WIP sales for the contrato.';
                Visible = false;
            }
            field("Calc. Recog. Sales Amount"; Rec."Calc. Recog. Sales Amount")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the sum of the recognized costs of the involved contrato tasks.';
                Visible = false;
            }
            field("Calc. Recog. Costs Amount"; Rec."Calc. Recog. Costs Amount")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the sum of the recognized costs of the involved contrato tasks.';
                Visible = false;
            }
        }
    }

    actions
    {
    }

    local procedure ShowDetails()
    begin
        PAGE.Run(PAGE::"Contrato Card", Rec);
    end;
}

