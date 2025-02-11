page 50228 "Contrato WIP Methods"
{
    AdditionalSearchTerms = 'work in process  to general ledger methods,work in progress to general ledger methods, Contrato WIP Methods';
    ApplicationArea = All;
    Caption = 'Contrato WIP Methods';
    PageType = List;
    SourceTable = "Contrato WIP Method";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the Contrato WIP Method. There are system-defined codes. In addition, you can create a Contrato WIP Method, and the code for it is in the list of Contrato WIP Methods.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the contrato WIP method. If the WIP method is system-defined, you cannot edit the description.';
                }
                field("Recognized Costs"; Rec."Recognized Costs")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a Recognized Cost option to apply when creating a calculation method for WIP. You must select one of the five options:';
                }
                field("Recognized Sales"; Rec."Recognized Sales")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a Recognized Sales option to apply when creating a calculation method for WIP. You must select one of the six options:';
                }
                field("WIP Cost"; Rec."WIP Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the calculation formula, depending on the parameters that you have specified when creating a calculation method for WIP. You can edit the check box, depending on the values set in the Recognized Costs and Recognized Sales fields.';
                }
                field("WIP Sales"; Rec."WIP Sales")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the parameters that apply when creating a calculation method for WIP. You can edit the check box, depending on the values set in the Recognized Costs and Recognized Sales fields.';
                }
                field(Valid; Rec.Valid)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether a WIP method can be associated with a contrato when you are creating or modifying a contrato. If you select this check box in the Contrato WIP Methods window, you can then set the method as a default WIP method in the contratos Setup window.';
                }
                field("System Defined"; Rec."System Defined")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether a Contrato WIP Method is system-defined.';
                }
            }
        }
    }

    actions
    {
    }
}

