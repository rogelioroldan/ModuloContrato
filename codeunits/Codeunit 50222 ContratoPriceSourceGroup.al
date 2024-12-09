codeunit 50222 "Price Source Group - Contrato" implements "Price Source Group"
{
    var
        ContratoSourceType: Enum "Contrato Price Source Type";

    procedure IsSourceTypeSupported(SourceType: Enum "Price Source Type"): Boolean;
    var
        Ordinals: list of [Integer];
    begin
        Ordinals := ContratoSourceType.Ordinals();
        exit(Ordinals.Contains(SourceType.AsInteger()))
    end;

    procedure GetGroup() SourceGroup: Enum "Price Source Group";
    begin
        exit(SourceGroup::Contrato);
    end;
}