page 50230 "Contrato WIP Totals"
{
    Caption = 'contrato WIP Totals';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "Contrato WIP Total";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Contrato Task No."; Rec."Contrato Task No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the contrato task that is associated with the contrato WIP total. The contrato task number is generally the final task in a group of tasks that is set to Total or the last contrato task line.';
                }
                field("WIP Method"; Rec."WIP Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the work in process (WIP) calculation method that is associated with a contrato. The value in the field comes from the WIP method specified on the contrato card.';
                }
                field("WIP Posting Date"; Rec."WIP Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when work in process (WIP) was last calculated and entered in the contrato WIP Entries window.';
                }
                field("WIP Warnings"; Rec."WIP Warnings")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if there are WIP warnings associated with a contrato for which you have calculated WIP.';
                }
                field("Schedule (Total Cost)"; Rec."Schedule (Total Cost)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total of the budgeted costs for the contrato.';
                }
                field("Schedule (Total Price)"; Rec."Schedule (Total Price)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total of the budgeted prices for the contrato.';
                }
                field("Usage (Total Cost)"; Rec."Usage (Total Cost)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies contrato usage in relation to total cost up to the date of the last contrato WIP calculation.';
                }
                field("Usage (Total Price)"; Rec."Usage (Total Price)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies contrato usage in relation to total price up to the date of the last contrato WIP calculation.';
                }
                field("Contract (Total Cost)"; Rec."Contract (Total Cost)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the billable in relation to total cost up to the date of the last contrato WIP calculation.';
                }
                field("Contract (Total Price)"; Rec."Contract (Total Price)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the billable in relation to the total price up to the date of the last contrato WIP calculation.';
                }
                field("Contract (Invoiced Price)"; Rec."Contract (Invoiced Price)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the price amount that has been invoiced and posted in relation to the billable for the current WIP calculation.';
                }
                field("Contract (Invoiced Cost)"; Rec."Contract (Invoiced Cost)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the cost amount that has been invoiced and posted in relation to the billable for the current WIP calculation.';
                }
                field("Calc. Recog. Sales Amount"; Rec."Calc. Recog. Sales Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the calculated sum of recognized sales amounts in the current WIP calculation.';
                }
                field("Calc. Recog. Costs Amount"; Rec."Calc. Recog. Costs Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the calculated sum of recognized costs amounts in the current WIP calculation.';
                }
                field("Cost Completion %"; Rec."Cost Completion %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the cost completion percentage for contrato tasks that have been budgeted in the current WIP calculation.';
                }
                field("Invoiced %"; Rec."Invoiced %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the percentage of contracted contrato tasks that have been invoiced in the current WIP calculation.';
                }
            }
        }
    }

    actions
    {
    }
}

