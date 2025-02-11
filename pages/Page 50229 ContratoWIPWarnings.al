page 50229 "Contrato WIP Warnings"
{
    Caption = 'Contrato WIP Warnings';
    PageType = List;
    SourceTable = "Contrato WIP Warning";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Contrato No."; Rec."Contrato No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the related contrato.';
                }
                field("Contrato Task No."; Rec."Contrato Task No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the related contrato task.';
                }
                field("Contrato WIP Total Entry No."; Rec."Contrato WIP Total Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number from the associated contrato WIP total.';
                }
                field("Warning Message"; Rec."Warning Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a warning message that is related to a contrato WIP calculation.';
                }
            }
        }
    }

    actions
    {
    }
}

