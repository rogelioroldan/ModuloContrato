namespace System.Threading;

page 50255 "Contrato Queue Category List"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Contrato Queue Categories';
    PageType = List;
    SourceTable = "Contrato Queue Category";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code for the category of Contrato queue. You can enter a maximum of 10 characters, both numbers and letters.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the Contrato queue category. You can enter a maximum of 30 characters, both numbers and letters.';
                }
            }
        }
    }

    actions
    {
    }
}

