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
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the number of the related project.';
                }
                field("Contrato Task No."; Rec."Contrato Task No.")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the number of the related project task.';
                }
                field("Contrato WIP Total Entry No."; Rec."Contrato WIP Total Entry No.")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the entry number from the associated project WIP total.';
                }
                field("Warning Message"; Rec."Warning Message")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies a warning message that is related to a project WIP calculation.';
                }
            }
        }
    }

    actions
    {
    }
}

