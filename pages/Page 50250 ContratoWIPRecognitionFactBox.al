page 50250 "ContratoWIP/RecognitionFactBox"
{
    Caption = 'Project Details - WIP/Recognition';
    PageType = CardPart;
    SourceTable = Contrato;

    layout
    {
        area(content)
        {
            field("No."; Rec."No.")
            {
                ApplicationArea = Contratos;
                Caption = 'Project No.';
                ToolTip = 'Specifies the project number.';

                trigger OnDrillDown()
                begin
                    ShowDetails();
                end;
            }
            field("WIP Posting Date"; Rec."WIP Posting Date")
            {
                ApplicationArea = Contratos;
                ToolTip = 'Specifies the posting date that was entered when the Project Calculate WIP batch Contrato was last run.';
            }
            field("Total WIP Cost Amount"; Rec."Total WIP Cost Amount")
            {
                ApplicationArea = Contratos;
                ToolTip = 'Specifies the total WIP cost amount that was last calculated for the project. The WIP Cost Amount for the project is the value WIP Cost Project WIP Entries less the value of the Recognized Cost Project WIP Entries. For projects with WIP Methods of Sales Value or Percentage of Completion, the WIP Cost Amount is normally 0.';
            }
            field("Applied Costs G/L Amount"; Rec."Applied Costs G/L Amount")
            {
                ApplicationArea = Contratos;
                ToolTip = 'Specifies the sum of all applied costs of the selected project.';
                Visible = false;
            }
            field("Total WIP Sales Amount"; Rec."Total WIP Sales Amount")
            {
                ApplicationArea = Contratos;
                ToolTip = 'Specifies the total WIP Sales amount that was last calculated for the project. The WIP Sales Amount for the project is the value WIP Sales Project WIP Entries less the value of the Recognized Sales Project WIP Entries. For projects with WIP Methods of Cost Value or Cost of Sales, the WIP Sales Amount is normally 0.';
            }
            field("Applied Sales G/L Amount"; Rec."Applied Sales G/L Amount")
            {
                ApplicationArea = Contratos;
                ToolTip = 'Specifies the sum of all applied costs of the selected project.';
                Visible = false;
            }
            field("Recog. Costs Amount"; Rec."Recog. Costs Amount")
            {
                ApplicationArea = Contratos;
                ToolTip = 'Specifies the Recognized Cost amount that was last calculated for the project. The Recognized Cost Amount for the project is the sum of the Recognized Cost Project WIP Entries.';
            }
            field("Recog. Sales Amount"; Rec."Recog. Sales Amount")
            {
                ApplicationArea = Contratos;
                ToolTip = 'Specifies the recognized sales amount that was last calculated for the project, which is the sum of the Recognized Sales Project WIP Entries.';
            }
            field("Recog. Profit Amount"; Rec.CalcRecognizedProfitAmount())
            {
                ApplicationArea = Contratos;
                Caption = 'Recog. Profit Amount';
                ToolTip = 'Specifies the recognized profit amount for the project.';
            }
            field("Recog. Profit %"; Rec.CalcRecognizedProfitPercentage())
            {
                ApplicationArea = Contratos;
                Caption = 'Recog. Profit %';
                ToolTip = 'Specifies the recognized profit percentage for the project.';
            }
            field("Acc. WIP Costs Amount"; Rec.CalcAccWIPCostsAmount())
            {
                ApplicationArea = Contratos;
                Caption = 'Acc. WIP Costs Amount';
                ToolTip = 'Specifies the total WIP costs for the project.';
                Visible = false;
            }
            field("Acc. WIP Sales Amount"; Rec.CalcAccWIPSalesAmount())
            {
                ApplicationArea = Contratos;
                Caption = 'Acc. WIP Sales Amount';
                ToolTip = 'Specifies the total WIP sales for the project.';
                Visible = false;
            }
            field("Calc. Recog. Sales Amount"; Rec."Calc. Recog. Sales Amount")
            {
                ApplicationArea = Contratos;
                ToolTip = 'Specifies the sum of the recognized costs of the involved project tasks.';
                Visible = false;
            }
            field("Calc. Recog. Costs Amount"; Rec."Calc. Recog. Costs Amount")
            {
                ApplicationArea = Contratos;
                ToolTip = 'Specifies the sum of the recognized costs of the involved project tasks.';
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
