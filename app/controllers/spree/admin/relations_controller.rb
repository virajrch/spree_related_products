module Spree
  module Admin
    class RelationsController < BaseController
      before_action :load_data, only:  [:create] # [:create, :destroy]

      respond_to :js, :html

      def create
        @relation = Relation.new(relation_params)
        if @relation_type.applies_to == "Spree::Product"
          @relation.relatable = @product
          @relation.related_to = Spree::Variant.find(relation_params[:related_to_id]).product
        else
          @relation.relatable = @variant
          @relation.related_to = Spree::Variant.find(relation_params[:related_to_id])
        end
        @relation.related_to_type = @relation_type.applies_to
        @relation.relatable_type = @relation_type.applies_to
        @relation.save

        respond_with(@relation)
      end

      def update
        @relation = Relation.find(params[:id])
        @relation.update_attribute :discount_amount, relation_params[:discount_amount] || 0
        @relation.update_attribute :quantity, relation_params[:quantity] || nil

        redirect_to(related_admin_product_url(@relation.relatable))
      end

      def update_positions
        params[:positions].each do |id, index|
          model_class.where(id: id).update_all(position: index)
        end

        respond_to do |format|
          format.js { render plain: 'Ok' }
        end
      end

      def destroy
        @relation = Relation.find(params[:id])
        @relation.destroy

        if @relation.destroy
          flash[:success] = flash_message_for(@relation, :successfully_removed)

          respond_with(@relation) do |format|
            format.html { redirect_to location_after_destroy }
            format.js   { render_js_for_destroy }
          end
        else
          respond_with(@relation) do |format|
            format.html { redirect_to location_after_destroy }
          end
        end
      end

      private

      def relation_params
        params.require(:relation).permit(*permitted_attributes)
      end

      def permitted_attributes
        [
          :related_to,
          :relation_type,
          :relatable,
          :related_to_id,
          :relatable_id,
          :discount_amount,
          :relation_type_id,
          :related_to_type,
          :position,
          :quantity
        ]
      end

      def load_data
        @product = Spree::Product.friendly.find(params[:product_id])
        @relation_type = Spree::RelationType.find(relation_params[:relation_type_id].to_i)
        @variant = Spree::Variant.find(relation_params[:relatable_id].to_i)
      end

      def model_class
        Spree::Relation
      end
    end
  end
end
