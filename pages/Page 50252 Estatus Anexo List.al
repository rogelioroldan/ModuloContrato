page 50252 "Estatus Anexo List"
{
    AdditionalSearchTerms = 'Estatus de anexos, Estatus Anexos';
    ApplicationArea = All;
    Caption = 'Estatus de Anexos';
    Editable = true;
    PageType = List;
    QueryCategory = 'Estatus Anexos';
    SourceTable = "EstatusAnexo";

    layout
    {
        area(content)
        {
            repeater(EstatusAnexo)
            {
                field("Código"; Rec."Código")
                {

                }
                field(Nombre; Rec.Nombre)
                { }
            }
        }
    }
}