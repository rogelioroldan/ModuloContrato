page 50227 "Contrato Producto Factura"
{
    Caption = 'Contrato Producto Factura';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Contrato Producto";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Código"; Rec."Código")
                {
                    ApplicationArea = All;
                }
                field("Nombre"; Rec."Nombre")
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    actions
    {
    }
}

