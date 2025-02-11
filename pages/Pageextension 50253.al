pageextension 50253 SalesInvoiceExt extends "Sales Invoice"
{
    actions
    {
        addafter("P&osting")
        {

            action("Post Contrato")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Post Contrato';
                Image = PostOrder;
                ToolTip = 'Post the sales invoice using the Sales-Post (Yes/No) Contrato codeunit.';

                trigger OnAction()
                begin
                    CallPostDocument(CODEUNIT::"Sales-Post (Yes/No) Contrato", Enum::"Navigate After Posting"::"Posted Document");
                end;
            }
        }
    }

}

